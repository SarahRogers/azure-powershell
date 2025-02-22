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

using Microsoft.Azure;
using Microsoft.Azure.Common.Authentication;
using Microsoft.Azure.Common.Authentication.Models;
using Microsoft.Rest;
using System;
using System.Security;

namespace Microsoft.WindowsAzure.Commands.Common.Test.Mocks
{
    public class MockTokenAuthenticationFactory : IAuthenticationFactory
    {
        public IAccessToken Token { get; set; }

        public Func<AzureAccount, AzureEnvironment, string, IAccessToken> TokenProvider { get; set; }

        public MockTokenAuthenticationFactory()
        {
            Token = new MockAccessToken
            {
                UserId = "Test",
                LoginType = LoginType.OrgId,
                AccessToken = "abc"
            };

            TokenProvider = (account, environment, tenant) => Token = new MockAccessToken
            {
                UserId = account.Id,
                LoginType = LoginType.OrgId,
                AccessToken = Token.AccessToken
            };
        }

        public MockTokenAuthenticationFactory(string userId, string accessToken)
        {
            Token = new MockAccessToken
            {
                UserId = userId,
                LoginType = LoginType.OrgId,
                AccessToken = accessToken
            };

            TokenProvider = ((account, environment, tenant) => Token);
        }

        public IAccessToken Authenticate(
            AzureAccount account,
            AzureEnvironment environment,
            string tenant,
            SecureString password,
            ShowDialog promptBehavior,
            IdentityModel.Clients.ActiveDirectory.TokenCache tokenCache,
            AzureEnvironment.Endpoint resourceId = AzureEnvironment.Endpoint.ActiveDirectoryServiceEndpointResourceId)
        {
            if (account.Id == null)
            {
                account.Id = "test";
            }

            if (TokenProvider == null)
            {
                return new MockAccessToken()
                {
                    AccessToken = account.Id,
                    LoginType = LoginType.OrgId,
                    UserId = account.Id
                };
            }
            else
            {
                return TokenProvider(account, environment, tenant);
            }
        }

        public IAccessToken Authenticate(
            AzureAccount account,
            AzureEnvironment environment,
            string tenant,
            SecureString password,
            ShowDialog promptBehavior,
            AzureEnvironment.Endpoint resourceId = AzureEnvironment.Endpoint.ActiveDirectoryServiceEndpointResourceId)
        {
            return Authenticate(account, environment, tenant, password, promptBehavior, AzureSession.TokenCache, resourceId);
        }
        
        public SubscriptionCloudCredentials GetSubscriptionCloudCredentials(AzureContext context)
        {
            return new AccessTokenCredential(context.Subscription.Id, Token);
        }
        
        public Microsoft.Rest.ServiceClientCredentials GetServiceClientCredentials(AzureContext context)
        {
            return new Microsoft.Rest.TokenCredentials(Token.AccessToken);
        }
    }
}
