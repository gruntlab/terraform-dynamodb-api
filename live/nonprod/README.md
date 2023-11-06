# terragrunt-dynamodb-api

Each of one of these commands are run via github actions

## VERSION Terragrunt

 ```terragrunt -version```

## INIT Terragrunt

```terragrunt init```

## VALIDATE Terragrunt

```terragrunt run-all validate```

## PLAN Terragrunt

```terragrunt run-all plan -var-file="nonprod.terraform.tfvars"```

## APPLY Terragrunt

```terragrunt run-all apply -var-file="nonprod.terraform.tfvars" --terragrunt-non-interactive```

## DESTROY Terragrunt

```terragrunt run-all destroy -var-file="nonprod.terraform.tfvars" --terragrunt-non-interactive```
