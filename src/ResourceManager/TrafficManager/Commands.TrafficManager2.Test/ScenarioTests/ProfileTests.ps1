﻿# ----------------------------------------------------------------------------------
#
# Copyright Microsoft Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------------

<#
.SYNOPSIS
Full Profile CRUD cycle
#>
function Test-ProfileCrud
{
	$profileName = getAssetName
	$resourceGroup = TestSetup-CreateResourceGroup
	$relativeName = getAssetName
	$createdProfile = New-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName -RelativeDnsName $relativeName -Ttl 50 -TrafficRoutingMethod "Performance" -MonitorProtocol "HTTP" -MonitorPort 80 -MonitorPath "/testpath.asp" 

	Assert-NotNull $createdProfile
	Assert-AreEqual $profileName $createdProfile.Name 
	Assert-AreEqual $resourceGroup.ResourceGroupName $createdProfile.ResourceGroupName 
	Assert-AreEqual "Performance" $createdProfile.TrafficRoutingMethod

	$retrievedProfile = Get-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName

	Assert-NotNull $retrievedProfile
	Assert-AreEqual $profileName $retrievedProfile.Name 
	Assert-AreEqual $resourceGroup.ResourceGroupName $retrievedProfile.ResourceGroupName

	$createdProfile.TrafficRoutingMethod = "Priority"

	$updatedProfile = Set-AzureRMTrafficManagerProfile -TrafficManagerProfile $createdProfile

	Assert-NotNull $updatedProfile
	Assert-AreEqual $profileName $updatedProfile.Name 
	Assert-AreEqual $resourceGroup.ResourceGroupName $updatedProfile.ResourceGroupName
	Assert-AreEqual "Priority" $updatedProfile.TrafficRoutingMethod

	$removed = Remove-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName -Force

	Assert-True { $removed }

	Assert-Throws { Get-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName }
}

<#
.SYNOPSIS
Full Profile CRUD cycle
#>
function Test-ProfileCrudWithPiping
{
	$profileName = getAssetName
    $resourceGroup = TestSetup-CreateResourceGroup
	$relativeName = getAssetName
	$createdProfile = New-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName -RelativeDnsName $relativeName -Ttl 50 -TrafficRoutingMethod "Performance" -MonitorProtocol "HTTP" -MonitorPort 80 -MonitorPath "/testpath.asp" 

	$createdProfile.TrafficRoutingMethod = "Priority"

	$removed = Get-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName | Set-AzureRMTrafficManagerProfile | Remove-AzureRMTrafficManagerProfile -Force

	Assert-True { $removed }

	Assert-Throws { Get-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName } 
}

<#
.SYNOPSIS
Delete a profile using the object instead of the parameters
#>
function Test-CreateDeleteUsingProfile
{
	$profileName = getAssetName
    $resourceGroup = TestSetup-CreateResourceGroup
	$relativeName = getAssetName
	$createdProfile = New-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName -RelativeDnsName $relativeName -Ttl 50 -TrafficRoutingMethod "Performance" -MonitorProtocol "HTTP" -MonitorPort 80 -MonitorPath "/testpath.asp" 

	Assert-NotNull $createdProfile
	Assert-AreEqual $profileName $createdProfile.Name 
	Assert-AreEqual $resourceGroup.ResourceGroupName $createdProfile.ResourceGroupName 
	Assert-AreEqual "Performance" $createdProfile.TrafficRoutingMethod

	Remove-AzureRMTrafficManagerProfile -TrafficManagerProfile $createdProfile -Force

	Assert-Throws { Get-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName } 
}

<#
.SYNOPSIS
Full cycle to create an Endpoint in a Profile
#>
function Test-CrudWithEndpoint
{
	$profileName = getAssetName
	$resourceGroup = TestSetup-CreateResourceGroup
	$relativeName = getAssetName
	$createdProfile = New-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName -RelativeDnsName $relativeName -Ttl 50 -TrafficRoutingMethod "Performance" -MonitorProtocol "HTTP" -MonitorPort 80 -MonitorPath "/testpath.asp" 

	$profileWithEndpoint = Add-AzureRMTrafficManagerEndpointConfig -EndpointName "MyExternalEndpoint" -TrafficManagerProfile $createdProfile -Type "ExternalEndpoints" -Target "www.contoso.com" -EndpointStatus "Enabled" -EndpointLocation "North Europe"

	$updatedProfile = Set-AzureRMTrafficManagerProfile -TrafficManagerProfile $profileWithEndpoint

	Assert-AreEqual 1 $updatedProfile.Endpoints.Count
}

<#
.SYNOPSIS
List profiles in resource group
#>
function Test-ListProfilesInResourceGroup
{
	$profileName = getAssetName
	$resourceGroup = TestSetup-CreateResourceGroup
	$relativeName = getAssetName
	$createdProfile = New-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName -RelativeDnsName $relativeName -Ttl 50 -TrafficRoutingMethod "Performance" -MonitorProtocol "HTTP" -MonitorPort 80 -MonitorPath "/testpath.asp" 

	$profiles = Get-AzureRMTrafficManagerProfile -ResourceGroupName $resourceGroup.ResourceGroupName

	Assert-AreEqual 1 $profiles.Count
}

<#
.SYNOPSIS
List profiles in subscription
#>
function Test-ListProfilesInSubscription
{
	$profileName = getAssetName
	$resourceGroup = TestSetup-CreateResourceGroup
	$relativeName = getAssetName
	$createdProfile = New-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName -RelativeDnsName $relativeName -Ttl 50 -TrafficRoutingMethod "Performance" -MonitorProtocol "HTTP" -MonitorPort 80 -MonitorPath "/testpath.asp" 

	$profiles = Get-AzureRMTrafficManagerProfile

	Assert-NotNull $profiles
}

<#
.SYNOPSIS
Create a Profile that already exists
#>
function Test-ProfileNewAlreadyExists
{
	$resourceGroup = TestSetup-CreateResourceGroup
	$profileName = getAssetName

    $createdProfile = TestSetup-CreateProfile $profileName $resourceGroup.ResourceGroupName
	$resourceGroupName = $createdProfile.ResourceGroupName

	Assert-NotNull $createdProfile
	
	Assert-Throws { TestSetup-CreateProfile $profileName $resourceGroup.ResourceGroupName } 

	$createdProfile | Remove-AzureRMTrafficManagerProfile -Force
}

<#
.SYNOPSIS
Remove a Profile that does not exist
#>
function Test-ProfileRemoveNonExisting
{
	$profileName = getAssetName
    $resourceGroup = TestSetup-CreateResourceGroup
	
	$removed = Remove-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName -Force 
	Assert-False { $removed }
}

<#
.SYNOPSIS
Enable existing disabled profile
#>
function Test-ProfileEnable
{
	$profileName = getAssetName
	$relativeName = getAssetName
    $resourceGroup = TestSetup-CreateResourceGroup
	
	$disabledProfile = New-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName -ProfileStatus "Disabled" -RelativeDnsName $relativeName -Ttl 50 -TrafficRoutingMethod "Performance" -MonitorProtocol "HTTP" -MonitorPort 80 -MonitorPath "/testpath.asp" 
	Assert-AreEqual "Disabled" $disabledProfile.ProfileStatus

    Assert-True { Enable-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName }

    $updatedProfile = Get-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName

    Assert-AreEqual "Enabled" $updatedProfile.ProfileStatus
}

<#
.SYNOPSIS
Enable existing disabled profile using pipeline
#>
function Test-ProfileEnablePipeline
{
	$profileName = getAssetName
	$relativeName = getAssetName
    $resourceGroup = TestSetup-CreateResourceGroup
	
	$disabledProfile = New-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName -ProfileStatus "Disabled" -RelativeDnsName $relativeName -Ttl 50 -TrafficRoutingMethod "Performance" -MonitorProtocol "HTTP" -MonitorPort 80 -MonitorPath "/testpath.asp" 
	Assert-AreEqual "Disabled" $disabledProfile.ProfileStatus

    Assert-True { Enable-AzureRMTrafficManagerProfile -TrafficManagerProfile $disabledProfile }

    $updatedProfile = Get-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName

    Assert-AreEqual "Enabled" $updatedProfile.ProfileStatus
}

<#
.SYNOPSIS
Enable non existing profile
#>
function Test-ProfileEnableNonExisting
{
	$profileName = getAssetName
    $resourceGroup = TestSetup-CreateResourceGroup

    Assert-Throws { Enable-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName } 
}

<#
.SYNOPSIS
Disable existing disabled profile
#>
function Test-ProfileDisable
{
	$profileName = getAssetName
	$relativeName = getAssetName
    $resourceGroup = TestSetup-CreateResourceGroup
	
	$enabledProfile = New-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName -ProfileStatus "Enabled" -RelativeDnsName $relativeName -Ttl 50 -TrafficRoutingMethod "Performance" -MonitorProtocol "HTTP" -MonitorPort 80 -MonitorPath "/testpath.asp" 
	
	Assert-AreEqual "Enabled" $enabledProfile.ProfileStatus

    Assert-True { Disable-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName -Force }

    $updatedProfile = Get-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName

    Assert-AreEqual "Disabled" $updatedProfile.ProfileStatus
}

<#
.SYNOPSIS
Disable existing disabled profile using pipeline
#>
function Test-ProfileDisablePipeline
{
	$profileName = getAssetName
	$relativeName = getAssetName
    $resourceGroup = TestSetup-CreateResourceGroup
	
	$enabledProfile = New-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName -ProfileStatus "Enabled" -RelativeDnsName $relativeName -Ttl 50 -TrafficRoutingMethod "Performance" -MonitorProtocol "HTTP" -MonitorPort 80 -MonitorPath "/testpath.asp" 
	Assert-AreEqual "Enabled" $enabledProfile.ProfileStatus

    Assert-True { Disable-AzureRMTrafficManagerProfile -TrafficManagerProfile $enabledProfile -Force }

    $updatedProfile = Get-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName

    Assert-AreEqual "Disabled" $updatedProfile.ProfileStatus
}

<#
.SYNOPSIS
Disable non existing profile
#>
function Test-ProfileDisableNonExisting
{
	$profileName = getAssetName
    $resourceGroup = TestSetup-CreateResourceGroup

    Assert-Throws { Disable-AzureRMTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup.ResourceGroupName -Force } 
}