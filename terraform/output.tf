output "identitystorage" {
  description = "SPN for storage."
  value       = module.blobstorage.identitystorage
}


output "identityfileshare" {
  description = "SPN for fileshare."
  value       = module.filestorage.identityfileshare 
}