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
Tests creating moving all resources in a resource group into another resource group.
#>
function Test-MoveAzureResource
{
    $sourceResourceGroupName = "testResourceGroup1"
    $destinationResourceGroupName = "testResourceGroup2"
    $testResourceName1 = "testResource1"
    $testResourceName2 = "testResource2"
    $location = "West US"
    $apiversion = "2014-04-01"
    $providerNamespace = "Providers.Test"
    $resourceType = $providerNamespace + "/statefulResources"

    Register-AzureRMProvider -ProviderNamespace $providerNamespace -Force
    New-AzureRMResourceGroup -Name $sourceResourceGroupName -Location $location -Force
    New-AzureRMResourceGroup -Name $destinationResourceGroupName -Location $location -Force
    $resource1 = New-AzureRMResource -Name $testResourceName1 -Location $location -Tags @{Name = "testtag"; Value = "testval"} -ResourceGroupName $sourceResourceGroupName -ResourceType $resourceType -PropertyObject @{"administratorLogin" = "adminuser"; "administratorLoginPassword" = "P@ssword1"} -ApiVersion $apiversion -Force
    $resource2 = New-AzureRMResource -Name $testResourceName2 -Location $location -Tags @{Name = "testtag"; Value = "testval"} -ResourceGroupName $sourceResourceGroupName -ResourceType $resourceType -PropertyObject @{"administratorLogin" = "adminuser"; "administratorLoginPassword" = "P@ssword1"} -ApiVersion $apiversion -Force

    Get-AzureRMResource -ResourceGroupName $sourceResourceGroupName | Move-AzureRMResource -DestinationResourceGroupName $destinationResourceGroupName -Force

    $endTime = [DateTime]::UtcNow.AddMinutes(10)

    while ([DateTime]::UtcNow -lt $endTime -and (@(Get-AzureRMResource -ResourceGroupName $sourceResourceGroupName).Length -gt 0))
    {
		[Microsoft.WindowsAzure.Commands.Utilities.Common.TestMockSupport]::Delay(1000)
    }

    Assert-True { @(Get-AzureRMResource -ResourceGroupName $sourceResourceGroupName).Length -eq 0 }
    Assert-True { @(Get-AzureRMResource -ResourceGroupName $destinationResourceGroupName).Length -eq 2 }
}
