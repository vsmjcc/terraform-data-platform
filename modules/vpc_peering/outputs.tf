output "peering_id" {
  value       = local.peering_id
  description = "ID do peering (use para operações manuais no peer, se necessário)."
}

output "acceptance_instructions" {
  description = "Passos/CLI para aceitar no peer quando manage_peer_side=false"
  value = var.manage_peer_side ? null : <<EOT
[PARCIAL] Aceitar peering na conta peer (zerezes):

1) Console: VPC -> Peering connections -> Selecione ${local.peering_id} -> Accept.

OU via CLI na conta peer:
aws ec2 accept-vpc-peering-connection --vpc-peering-connection-id ${local.peering_id}

2) Habilitar DNS remoto no peering (peer side):
aws ec2 modify-vpc-peering-connection-options \
  --vpc-peering-connection-id ${local.peering_id} \
  --accepter-peering-connection-options AllowDnsResolutionFromRemoteVpc=true

3) Criar rotas (peer -> requester) nas RTs privadas do peer:
for RT in <rtb-PEER-1> <rtb-PEER-2>; do
  aws ec2 create-route --route-table-id $RT \
    --destination-cidr-block ${var.requester_vpc_cidr} \
    --vpc-peering-connection-id ${local.peering_id} || true
done

4) (Opcional) Abrir SG do RDS (peer):
# SG->SG (se souber o SG da app no requester, mesma região)
aws ec2 authorize-security-group-ingress \
  --group-id <peer_rds_sg_id> --protocol tcp --port ${var.db_port} \
  --source-group <requester_app_sg_id>

# ou por CIDR do requester:
aws ec2 authorize-security-group-ingress \
  --group-id <peer_rds_sg_id> --protocol tcp --port ${var.db_port} \
  --cidr ${var.requester_vpc_cidr}
EOT
}