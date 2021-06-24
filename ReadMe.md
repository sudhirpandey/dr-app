#Log In into AWs
```
aws sso login profile=dev-account
```

#DR Infra Deploy per env with var files
```
cd infra_terrafrom
terraform init 
terrafrom plan -var-file=env_vars/dev.tfvars
terrafrom deploy
```


#Application deploy in both regions
```
 for region in eu-north-1 eu-west-1; do aws eks update-kubeconfig --region $region --name eks-cluster && kubectl apply -k app_k8s/overlays/$region; done
 ```

 After doing this the web application will be reach able via domain name send as variable in  dev.tfvars.
