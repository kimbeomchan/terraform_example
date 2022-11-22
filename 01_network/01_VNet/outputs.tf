# output "vnet_id" {
#   description = "Specifies the resource id of the virtual network"
#   value       = module.vnet.id
# }

# output "subnet_ids" {
#   description = "Contains a list of the the resource id of the subnets"
#   value       = { for subnet in module.vnet : subnet.subnet_names => subnet.id }
# }
