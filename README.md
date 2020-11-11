# DockerInstallDsc
Powershell DSC Resource to install Docker for Windows on Windows Server 

# DSC Resources
## DockerInstall
### Parameters
|Parameter|Attribute|DataType|Description|Allowed Values|
|---------|---------|--------|-----------|--------------|
|DockerVersion|Key|String|Version of Docker to Install ('18.03' e. g.)||
|InstallState|NotConfigurable|String|Current State of Docker| Absent,Present|
|Ensure|Write|String|Supposed State of Docker|Absent,Present|
|DockerName|NotConfigurable|String|Name of currently installed Docker Runtime||

### Description
The DockerInstall Class DSC Resource allows to install, uninstall or update Docker on Windows Server.

### Examples
``` 
configuration example_docker_install {
    param (
        # Node Name
        [Parameter(Mandatory=$false)]
        [string]
        $NodeName = 'localhost'
    )

    Import-DscResource -ModuleName PSDscResources
    Import-DscResource -ModuleName PackageManagement
    Import-DscResource -ModuleName DockerInstall

    node $NodeName
    {
        #region WindowsFeatures
        WindowsFeature Containers
        {
            Ensure = 'Present'
            Name = 'Containers'
        }
        #endregion

        #region Package Management
        PackageManagement 'DockerMsftProvider'
        {
            Ensure               = 'Present'
            Name                 = 'DockerMsftProvider'
            Source               = 'PSGallery'
            RequiredVersion      = '1.0.0.8'
        }
        #endregion

        #region Install Docker
        DockerInstall Docker-EE {
            Ensure = 'Present'
            DockerVersion = '19.03'
            DependsOn = '[PackageManagement]DockerMsftProvider'
        }

        Service Docker-srv {
            Name = 'docker'
            State = 'Running'
            DependsOn = '[DockerInstall]Docker-EE'
        }
        #endregion
    }
}
```