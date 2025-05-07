install terraform
install azure cli
authenticate azure
```
az login
```


deploy tf file
```
terraform init
terraform validate
terraform apply
```

Create func
```
func init
func new

func azure functionapp publish <name>
```

if not sure what function is, use the following command
```
az functionapp list --query "[].name"
```

# Run locally

* ample of local.settings.json
```
{
  "IsEncrypted": false,
  "Values": {
    "FUNCTIONS_WORKER_RUNTIME": "node",
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "AzureWebJobs.HttpExample.Disabled": "true"
  }
}
```
* art azurite service in VScode, start all blob, queue and table services
* create storage account in local emulator and upload a test file
* run blobtrigger service, should see logs
