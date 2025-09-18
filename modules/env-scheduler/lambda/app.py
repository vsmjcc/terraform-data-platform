
import os
import logging
import boto3

log = logging.getLogger()
log.setLevel(logging.INFO)

TAG_KEY    = os.getenv("TAG_KEY", "Environment")
TAG_VALUES = [v.strip() for v in os.getenv("TAG_VALUES", "dev").split(",") if v.strip()]

MANAGE_ECS = os.getenv("MANAGE_ECS", "true").lower() == "true"
MANAGE_ASG = os.getenv("MANAGE_ASG", "true").lower() == "true"
MANAGE_EC2 = os.getenv("MANAGE_EC2", "true").lower() == "true"
MANAGE_RDS = os.getenv("MANAGE_RDS", "true").lower() == "true"

ECS_DESIRED_DEFAULT_ON_START = int(os.getenv("ECS_DESIRED_DEFAULT_ON_START", "1"))
ASG_DEFAULT_MIN     = int(os.getenv("ASG_DEFAULT_MIN", "1"))
ASG_DEFAULT_MAX     = int(os.getenv("ASG_DEFAULT_MAX", "1"))
ASG_DEFAULT_DESIRED = int(os.getenv("ASG_DEFAULT_DESIRED", "1"))

TAG_ECS_ORIG    = "scheduler:origDesired"
TAG_ASG_MIN     = "scheduler:asg:origMin"
TAG_ASG_MAX     = "scheduler:asg:origMax"
TAG_ASG_DESIRED = "scheduler:asg:origDesired"

ecs = boto3.client("ecs")
asg = boto3.client("autoscaling")
ec2 = boto3.client("ec2")
rds = boto3.client("rds")

def _matches(tags: dict) -> bool:
    val = tags.get(TAG_KEY)
    return val in TAG_VALUES

# -------------- ECS --------------
def stop_ecs():
    clusters = ecs.list_clusters().get("clusterArns", [])
    for cluster in clusters:
        services = []
        next_token = None
        while True:
            req = {"cluster": cluster}
            if next_token:
                req["nextToken"] = next_token
            out = ecs.list_services(**req)
            services += out.get("serviceArns", [])
            next_token = out.get("nextToken")
            if not next_token:
                break
        if not services:
            continue
        desc = ecs.describe_services(cluster=cluster, services=services)
        for svc in desc.get("services", []):
            try:
                t = ecs.list_tags_for_resource(resourceArn=svc["serviceArn"]).get("tags", [])
                tags = {x.get("key"): x.get("value") for x in t}
            except Exception:
                tags = {}
            if not _matches(tags):
                continue
            current = svc.get("desiredCount", 0)
            if current and TAG_ECS_ORIG not in tags:
                ecs.tag_resource(resourceArn=svc["serviceArn"], tags=[{"key": TAG_ECS_ORIG, "value": str(current)}])
            if current != 0:
                log.info(f"[ECS] {svc['serviceName']} -> 0")
                ecs.update_service(cluster=cluster, service=svc["serviceName"], desiredCount=0, forceNewDeployment=False)

def start_ecs():
    clusters = ecs.list_clusters().get("clusterArns", [])
    for cluster in clusters:
        services = []
        next_token = None
        while True:
            req = {"cluster": cluster}
            if next_token:
                req["nextToken"] = next_token
            out = ecs.list_services(**req)
            services += out.get("serviceArns", [])
            next_token = out.get("nextToken")
            if not next_token:
                break
        if not services:
            continue
        desc = ecs.describe_services(cluster=cluster, services=services)
        for svc in desc.get("services", []):
            try:
                t = ecs.list_tags_for_resource(resourceArn=svc["serviceArn"]).get("tags", [])
                tags = {x.get("key"): x.get("value") for x in t}
            except Exception:
                tags = {}
            if not _matches(tags):
                continue
            desired = int(tags.get(TAG_ECS_ORIG, ECS_DESIRED_DEFAULT_ON_START))
            log.info(f"[ECS] {svc['serviceName']} -> {desired}")
            ecs.update_service(cluster=cluster, service=svc["serviceName"], desiredCount=desired, forceNewDeployment=False)

# -------------- ASG --------------
def stop_asg():
    groups = asg.describe_auto_scaling_groups().get("AutoScalingGroups", [])
    for g in groups:
        tags = {t["Key"]: t["Value"] for t in g.get("Tags", [])}
        if not _matches(tags):
            continue
        orig_min = str(g.get("MinSize", 0))
        orig_max = str(g.get("MaxSize", 0))
        orig_desired = str(g.get("DesiredCapacity", 0))
        asg.create_or_update_tags(Tags=[
            {"ResourceId": g["AutoScalingGroupName"], "ResourceType": "auto-scaling-group", "Key": TAG_ASG_MIN, "Value": orig_min, "PropagateAtLaunch": False},
            {"ResourceId": g["AutoScalingGroupName"], "ResourceType": "auto-scaling-group", "Key": TAG_ASG_MAX, "Value": orig_max, "PropagateAtLaunch": False},
            {"ResourceId": g["AutoScalingGroupName"], "ResourceType": "auto-scaling-group", "Key": TAG_ASG_DESIRED, "Value": orig_desired, "PropagateAtLaunch": False},
        ])
        log.info(f"[ASG] {g['AutoScalingGroupName']} -> 0/0/0")
        asg.update_auto_scaling_group(
            AutoScalingGroupName=g["AutoScalingGroupName"],
            MinSize=0, MaxSize=0, DesiredCapacity=0
        )

def start_asg():
    groups = asg.describe_auto_scaling_groups().get("AutoScalingGroups", [])
    for g in groups:
        tags = {t["Key"]: t["Value"] for t in g.get("Tags", [])}
        if not _matches(tags):
            continue
        min_v = int(tags.get(TAG_ASG_MIN, str(ASG_DEFAULT_MIN)))
        max_v = int(tags.get(TAG_ASG_MAX, str(ASG_DEFAULT_MAX)))
        desired_v = int(tags.get(TAG_ASG_DESIRED, str(ASG_DEFAULT_DESIRED)))
        log.info(f"[ASG] {g['AutoScalingGroupName']} -> {min_v}/{max_v}/{desired_v}")
        asg.update_auto_scaling_group(
            AutoScalingGroupName=g["AutoScalingGroupName"],
            MinSize=min_v, MaxSize=max_v, DesiredCapacity=desired_v
        )

# -------------- EC2 --------------
def stop_ec2():
    desc = ec2.describe_instances(
        Filters=[
            {"Name": "instance-state-name", "Values": ["running", "pending"]},
            {"Name": f"tag:{TAG_KEY}", "Values": TAG_VALUES}
        ]
    )
    ids = [i["InstanceId"] for r in desc.get("Reservations", []) for i in r.get("Instances", [])]
    if ids:
        log.info(f"[EC2] stopping {ids}")
        ec2.stop_instances(InstanceIds=ids)

def start_ec2():
    desc = ec2.describe_instances(
        Filters=[
            {"Name": "instance-state-name", "Values": ["stopped"]},
            {"Name": f"tag:{TAG_KEY}", "Values": TAG_VALUES}
        ]
    )
    ids = [i["InstanceId"] for r in desc.get("Reservations", []) for i in r.get("Instances", [])]
    if ids:
        log.info(f"[EC2] starting {ids}")
        ec2.start_instances(InstanceIds=ids)

# -------------- RDS --------------
def stop_rds():
    dbs = rds.describe_db_instances().get("DBInstances", [])
    for db in dbs:
        arn = db.get("DBInstanceArn")
        tags = {t['Key']: t['Value'] for t in rds.list_tags_for_resource(ResourceName=arn).get("TagList", [])}
        if not _matches(tags):
            continue
        status = db.get("DBInstanceStatus")
        engine = db.get("Engine", "")
        if status in ("available", "backing-up"):
            if "aurora" in engine:
                log.info(f"[RDS] skip instance-level stop for {db['DBInstanceIdentifier']} (Aurora)")
                continue
            log.info(f"[RDS] stopping {db['DBInstanceIdentifier']}")
            rds.stop_db_instance(DBInstanceIdentifier=db["DBInstanceIdentifier"])

def start_rds():
    dbs = rds.describe_db_instances().get("DBInstances", [])
    for db in dbs:
        arn = db.get("DBInstanceArn")
        tags = {t['Key']: t['Value'] for t in rds.list_tags_for_resource(ResourceName=arn).get("TagList", [])}
        if not _matches(tags):
            continue
        status = db.get("DBInstanceStatus")
        engine = db.get("Engine", "")
        if status == "stopped":
            if "aurora" in engine:
                log.info(f"[RDS] skip instance-level start for {db['DBInstanceIdentifier']} (Aurora)")
                continue
            log.info(f"[RDS] starting {db['DBInstanceIdentifier']}")
            rds.start_db_instance(DBInstanceIdentifier=db["DBInstanceIdentifier"])

def handler(event, context):
    action = (event or {}).get("action") or os.getenv("ACTION", "stop")
    action = action.lower()
    log.info(f"ACTION={action} TAG_KEY={TAG_KEY} TAG_VALUES={TAG_VALUES}")
    if action == "stop":
        if MANAGE_ECS: stop_ecs()
        if MANAGE_ASG: stop_asg()
        if MANAGE_EC2: stop_ec2()
        if MANAGE_RDS: stop_rds()
    elif action == "start":
        if MANAGE_RDS: start_rds()
        if MANAGE_ASG: start_asg()
        if MANAGE_EC2: start_ec2()
        if MANAGE_ECS: start_ecs()
    else:
        log.warning("Unknown action")
    return {"ok": True, "action": action}
