﻿// ----------------------------------------------------------------------------------
//
// Copyright Microsoft Corporation
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ----------------------------------------------------------------------------------

using Microsoft.WindowsAzure.Commands.Utilities.Common;
using Microsoft.Azure.Commands.Profile;
using Microsoft.Azure.Commands.ResourceManager.Common;
using Microsoft.Azure.Common.Authentication;
using Microsoft.Azure.Common.Authentication.Models;
using Microsoft.WindowsAzure.Commands.Common.Test.Mocks;
using Microsoft.WindowsAzure.Commands.ScenarioTest;
using System.Linq;
using Xunit;
using System;
using Microsoft.WindowsAzure.Commands.Test.Utilities.Common;
using Hyak.Common;
using System.Management.Automation;

namespace Microsoft.Azure.Commands.Profile.Test
{
    public class TenantCmdletTests
    {
        private MemoryDataStore dataStore;
        private MockCommandRuntime commandRuntimeMock;

        public TenantCmdletTests()
        {
            dataStore = new MemoryDataStore();
            AzureSession.DataStore = dataStore;
            commandRuntimeMock = new MockCommandRuntime();
            AzureRMCmdlet.DefaultProfile = new AzureRMProfile();
        }

        [Fact]
        [Trait(Category.AcceptanceType, Category.LiveOnly)]
        public void GetTenantWithTenantParameter()
        {
            var cmdlt = new GetAzureRMTenantCommand();
            // Setup
            cmdlt.CommandRuntime = commandRuntimeMock;
            cmdlt.Tenant = "72f988bf-86f1-41af-91ab-2d7cd011db47";

            // Act
            Login("2c224e7e-3ef5-431d-a57b-e71f4662e3a6", null);
            cmdlt.InvokeBeginProcessing();
            cmdlt.ExecuteCmdlet();
            cmdlt.InvokeEndProcessing();
            
            Assert.True(commandRuntimeMock.OutputPipeline.Count == 2);
            Assert.Equal("72f988bf-86f1-41af-91ab-2d7cd011db47", ((AzureTenant)commandRuntimeMock.OutputPipeline[1]).Id.ToString());
            Assert.Equal("microsoft.com", ((AzureTenant)commandRuntimeMock.OutputPipeline[1]).Domain);
        }
        
        [Fact]
        [Trait(Category.AcceptanceType, Category.LiveOnly)]
        public void GetTenantWithDomainParameter()
        {
            var cmdlt = new GetAzureRMTenantCommand();
            // Setup
            cmdlt.CommandRuntime = commandRuntimeMock;
            cmdlt.Tenant = "microsoft.com";

            // Act
            Login("2c224e7e-3ef5-431d-a57b-e71f4662e3a6", null);
            cmdlt.InvokeBeginProcessing();
            cmdlt.ExecuteCmdlet();
            cmdlt.InvokeEndProcessing();

            Assert.True(commandRuntimeMock.OutputPipeline.Count == 2);
            Assert.Equal("72f988bf-86f1-41af-91ab-2d7cd011db47", ((AzureTenant)commandRuntimeMock.OutputPipeline[1]).Id.ToString());
            Assert.Equal("microsoft.com", ((AzureTenant)commandRuntimeMock.OutputPipeline[1]).Domain);
        }
        
        [Fact]
        [Trait(Category.AcceptanceType, Category.LiveOnly)]
        public void GetTenantWithoutParameters()
        {
            var cmdlt = new GetAzureRMTenantCommand();
            // Setup
            cmdlt.CommandRuntime = commandRuntimeMock;

            // Act
            Login("2c224e7e-3ef5-431d-a57b-e71f4662e3a6", null);
            cmdlt.InvokeBeginProcessing();
            cmdlt.ExecuteCmdlet();
            cmdlt.InvokeEndProcessing();

            Assert.True(commandRuntimeMock.OutputPipeline.Count == 2);
            Assert.Equal("72f988bf-86f1-41af-91ab-2d7cd011db47", ((AzureTenant)commandRuntimeMock.OutputPipeline[1]).Id.ToString());
            Assert.Equal("microsoft.com", ((AzureTenant)commandRuntimeMock.OutputPipeline[1]).Domain);
        }

        private void Login(string subscriptionId, string tenantId)
        {
            var cmdlt = new LoginAzureRMAccountCommand();
            // Setup
            cmdlt.CommandRuntime = commandRuntimeMock;
            cmdlt.SubscriptionId = subscriptionId;
            cmdlt.Tenant = tenantId;

            // Act
            cmdlt.InvokeBeginProcessing();
            cmdlt.ExecuteCmdlet();
            cmdlt.InvokeEndProcessing();

            Assert.NotNull(AzureRMCmdlet.DefaultProfile.Context);
        }
    }
}
