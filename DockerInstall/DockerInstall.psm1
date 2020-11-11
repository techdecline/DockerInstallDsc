enum Ensure { 
    Absent
    Present
}

[DscResource()]
class DockerInstall {
    [DscProperty(Key)]
    [String]$DockerVersion

    [DscProperty(NotConfigurable)]
    [String]$InstallState

    [DscProperty(Mandatory=$false)]
    [String]$Ensure = 'Present'

    [DscProperty(NotConfigurable)]
    [String]$DockerName

    # Gets the resource's current state.
    [DockerInstall] Get() {
        try {
            $dockerArr = (docker version 2>0) -split '\n' | Select-Object -First 2 | ForEach-Object {($_ -replace "^.*:").trim()}
            $this.InstallState = 'Present'
            foreach ($dockerProp in $dockerArr) {
                switch -regex ($dockerProp) {
                    "^Docker.*" {
                        $this.DockerName = $dockerProp
                    }
                    "^\d{2}\.\d{2}\.\d{2}" {
                        $this.DockerVersion = $dockerProp
                    }
                }
            }
        }
        catch [System.Management.Automation.CommandNotFoundException] {
            $this.InstallState = 'Absent'
        }
        return $this
    }
    
    # Sets the desired state of the resource.
    [void] Set() {
        Write-Verbose "Desired State is: $($this.Ensure)"
        switch ($this.Ensure) {
            "Absent" {
                Uninstall-Package -Name docker -ProviderName DockerMsftProvider -Force

            }
            "Present" {
                Install-Package -Name docker -ProviderName DockerMsftProvider -Force -RequiredVersion $this.DockerVersion
            }
        }
    }
    
    # Tests if the resource is in the desired state.
    [bool] Test() {
        foreach($level in "Machine","User") {
            [Environment]::GetEnvironmentVariables($level)
        }
        $dockerInfo = $this.Get()
        if ($dockerInfo.InstallState -eq $this.Ensure) {
            return $true
        }
        else {
            return $false
        }
    }
}