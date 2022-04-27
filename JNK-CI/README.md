# PACKAGES on-demand update 

## Trigger packages build

- The package creation is triggered by an parametrized API call performed through Github actions to the Jenkins instance:
		- the parameters passed are, Galaxy version, Galaxy image, Galaxy flavor.

## Jenkins pipeline 

- Use Terraform to create a Galaxy Virtual Machine on Openstack 
- Install flavor Galaxy tools using [ansible-role-laniakea-galaxy-tools](https://github.com/Laniakea-elixir-it/ansible-role-laniakea-galaxy-tools)  
- Perform the packages creation by calling the playbook `dump.yml`
- Upload the packeges on the Openstack object storage Swift  `swift_upload.yml`
- Trigger CVMFS_JenkinsFile on success `CVMFS_JenkinsFile`

## CVMFS_JenkinsFile

- Upload the packages on the buffer volume of the CVMFS Stratum0 tools.elixir-italy-cvmfs
- Open the CVMFS transaction
- Publish the new data
- Update the version

##  Pipeline Schema 
![plot](package_update.png)
