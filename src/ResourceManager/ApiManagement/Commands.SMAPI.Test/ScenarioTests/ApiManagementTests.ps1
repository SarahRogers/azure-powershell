﻿<#
.SYNOPSIS
Tests CRUD operations of API.
#>
function Api-CrudTest
{
Param($resourceGroupName, $serviceName)

    $context = New-AzureRMApiManagementContext -ResourceGroupName $resourceGroupName -ServiceName $serviceName

    # get all apis
    $apis = Get-AzureRMApiManagementApi -Context $context

    # there should be one API
    Assert-AreEqual 1 $apis.Count
    Assert-NotNull $apis[0].ApiId
    Assert-AreEqual "Echo API" $apis[0].Name
    Assert-Null $apis[0].Description
    Assert-AreEqual "http://echoapi.cloudapp.net/api" $apis[0].ServiceUrl
    Assert-AreEqual echo $apis[0].Path
    Assert-AreEqual 1 $apis[0].Protocols.Length
    Assert-AreEqual https $apis[0].Protocols[0]
    Assert-Null $apis[0].AuthorizationServerId
    Assert-Null $apis[0].AuthorizationScope
    Assert-Null $apis[0].SubscriptionKeyHeaderName
    Assert-Null $apis[0].SubscriptionKeyQueryParamName

    # get by ID
    $apiId = $apis[0].ApiId

    $api = Get-AzureRMApiManagementApi -Context $context -ApiId $apiId

    Assert-AreEqual $apiId $api.ApiId
    Assert-AreEqual "Echo API" $api.Name
    Assert-Null $api.Description
    Assert-AreEqual "http://echoapi.cloudapp.net/api" $api.ServiceUrl
    Assert-AreEqual echo $api.Path
    Assert-AreEqual 1 $api.Protocols.Length
    Assert-AreEqual https $api.Protocols[0]
    Assert-Null $api.AuthorizationServerId
    Assert-Null $api.AuthorizationScope
    Assert-NotNull $api.SubscriptionKeyHeaderName       #TODO: this is odd
    Assert-NotNull $api.SubscriptionKeyQueryParamName   #TODO: this is odd

    # get by Name
    $apiName = $apis[0].Name

    $apis = Get-AzureRMApiManagementApi -Context $context -Name $apiName

    Assert-AreEqual 1 $apis.Count
    Assert-NotNull $apis[0].ApiId
    Assert-AreEqual $apiName $apis[0].Name
    Assert-Null $apis[0].Description
    Assert-AreEqual "http://echoapi.cloudapp.net/api" $apis[0].ServiceUrl
    Assert-AreEqual echo $apis[0].Path
    Assert-AreEqual 1 $apis[0].Protocols.Length
    Assert-AreEqual https $apis[0].Protocols[0]
    Assert-Null $apis[0].AuthorizationServerId
    Assert-Null $apis[0].AuthorizationScope
    Assert-Null $apis[0].SubscriptionKeyHeaderName
    Assert-Null $apis[0].SubscriptionKeyQueryParamName

    # create new api
    $newApiId = getAssetName
    try
    {
        $newApiName = getAssetName
        $newApiDescription = getAssetName
        $newApiPath = getAssetName
        $newApiServiceUrl = "http://newechoapi.cloudapp.net/newapi"
        $subscriptionKeyParametersHeader = getAssetName
        $subscriptionKeyQueryStringParamName = getAssetName

        $newApi = New-AzureRMApiManagementApi -Context $context -ApiId $newApiId -Name $newApiName -Description $newApiDescription `
        -Protocols @("http", "https") -Path $newApiPath -ServiceUrl $newApiServiceUrl `
        -SubscriptionKeyHeaderName $subscriptionKeyParametersHeader -SubscriptionKeyQueryParamName $subscriptionKeyQueryStringParamName

        Assert-AreEqual $newApiId $newApi.ApiId
        Assert-AreEqual $newApiName $newApi.Name
        Assert-AreEqual $newApiDescription.Description
        Assert-AreEqual $newApiServiceUrl $newApi.ServiceUrl
        Assert-AreEqual $newApiPath $newApi.Path
        Assert-AreEqual 2 $newApi.Protocols.Length
        Assert-AreEqual http $newApi.Protocols[0]
        Assert-AreEqual https $newApi.Protocols[1]
        Assert-Null $newApi.AuthorizationServerId
        Assert-Null $newApi.AuthorizationScope
        Assert-AreEqual $subscriptionKeyParametersHeader $newApi.SubscriptionKeyHeaderName      
        Assert-AreEqual $subscriptionKeyQueryStringParamName $newApi.SubscriptionKeyQueryParamName  

        # set api
        $newApiName = getAssetName
        $newApiDescription = getAssetName
        $newApiPath = getAssetName
        $newApiServiceUrl = "http://newechoapi.cloudapp.net/newapinew"
        $subscriptionKeyParametersHeader = getAssetName
        $subscriptionKeyQueryStringParamName = getAssetName

        $newApi = Set-AzureRMApiManagementApi -Context $context -ApiId $newApiId -Name $newApiName -Description $newApiDescription `
        -Protocols @("https") -Path $newApiPath -ServiceUrl $newApiServiceUrl `
        -SubscriptionKeyHeaderName $subscriptionKeyParametersHeader -SubscriptionKeyQueryParamName $subscriptionKeyQueryStringParamName `
        -PassThru

        Assert-AreEqual $newApiId $newApi.ApiId
        Assert-AreEqual $newApiName $newApi.Name
        Assert-AreEqual $newApiDescription.Description
        Assert-AreEqual $newApiServiceUrl $newApi.ServiceUrl
        Assert-AreEqual $newApiPath $newApi.Path
        Assert-AreEqual 1 $newApi.Protocols.Length
        Assert-AreEqual https $newApi.Protocols[0]
        Assert-Null $newApi.AuthorizationServerId
        Assert-Null $newApi.AuthorizationScope
        Assert-AreEqual $subscriptionKeyParametersHeader $newApi.SubscriptionKeyHeaderName
        Assert-AreEqual $subscriptionKeyQueryStringParamName $newApi.SubscriptionKeyQueryParamName

        $product = Get-AzureRMApiManagementProduct -Context $context | Select -First 1
        Add-AzureRMApiManagementApiToProduct -Context $context -ApiId $newApiId -ProductId $product.ProductId

        #get by product id
        $found = 0
        $apis = Get-AzureRMApiManagementApi -Context $context -ProductId $product.ProductId
        for ($i = 0; $i -lt $apis.Count; $i++)
        {
            if($apis[$i].ApiId -eq $newApiId)
            {
                $found = 1
            }
        }
        Assert-AreEqual 1 $found

        Remove-AzureRMApiManagementApiFromProduct -Context $context -ApiId $newApiId -ProductId $product.ProductId
        $found = 0
        $apis = Get-AzureRMApiManagementApi -Context $context -ProductId $product.ProductId
        for ($i = 0; $i -lt $apis.Count; $i++)
        {
            if($apis[$i].ApiId -eq $newApiId)
            {
                $found = 1
            }
        }
        Assert-AreEqual 0 $found
    }
    finally
    {
        # remove created api
        $removed = Remove-AzureRMApiManagementApi -Context $context -ApiId $newApiId -PassThru -Force
        Assert-True {$removed}
    }
}

<#
.SYNOPSIS
Tests API import/export.
#>
function Api-ImportExportTest
{
Param($resourceGroupName, $serviceName)

    $context = New-AzureRMApiManagementContext -ResourceGroupName $resourceGroupName -ServiceName $serviceName

    $wadlPath = "./Resources/WADLYahoo.xml"
    $path = "wadlapi"
    $wadlApiId = getAssetName

    try
    {
        # import api from file
        $api = Import-AzureRMApiManagementApi -Context $context -ApiId $wadlApiId -SpecificationPath $wadlPath -SpecificationFormat Wadl -Path $path

        Assert-AreEqual $wadlApiId $api.ApiId
        Assert-AreEqual $path $api.Path

        # export api to pipline
        $result = Export-AzureRMApiManagementApi -Context $context -ApiId $wadlApiId -SpecificationFormat Wadl

        Assert-True {$result -like '*<doc title="Yahoo News Search">Yahoo News Search API</doc>*'}
    }
    finally
    {
        # remove created api
        $removed = Remove-AzureRMApiManagementApi -Context $context -ApiId $wadlApiId -PassThru -Force
        Assert-True {$removed}
    }
}

<#
.SYNOPSIS
Tests CRUD operations of Operations.
#>
function Operations-CrudTest
{
Param($resourceGroupName, $serviceName)

    $context = New-AzureRMApiManagementContext -ResourceGroupName $resourceGroupName -ServiceName $serviceName

    # get api
    $api = Get-AzureRMApiManagementApi -Context $context -Name 'Echo API'| Select -First 1

    # get all api operations
    $operations = Get-AzureRMApiManagementOperation -Context $context -ApiId $api.ApiId

    Assert-AreEqual 6 $operations.Count
    for ($i = 0; $i -lt $operations.Count; $i++)
    {
        Assert-AreEqual $api.ApiId $operations[$i].ApiId

        $operation = Get-AzureRMApiManagementOperation -Context $context -ApiId $api.ApiId -OperationId $operations[$i].OperationId

        Assert-AreEqual $api.ApiId $operation.ApiId
        Assert-AreEqual $operations[$i].OperationId $operation.OperationId
        Assert-AreEqual $operations[$i].Name $operation.Name
        Assert-AreEqual $operations[$i].Description $operation.Description
        Assert-AreEqual $operations[$i].Method $operation.Method
        Assert-AreEqual $operations[$i].UrlTemplate $operation.UrlTemplate
    }

    #add new operation
    $newOperationId = getAssetName
    try
    {
        $newOperationName = getAssetName
        $newOperationMethod = "PATCH"
        $newperationUrlTemplate = "/resource/{rid}?q={query}"
        $newOperationDescription = getAssetName
        $newOperationRequestDescription = getAssetName

        $newOperationRequestHeaderParamName = getAssetName
        $newOperationRequestHeaderParamDescr = getAssetName
        $newOperationRequestHeaderParamIsRequired = $TRUE
        $newOperationRequestHeaderParamDefaultValue = getAssetName
        $newOperationRequestHeaderParamType = "string"

        $newOperationRequestParmName = getAssetName
        $newOperationRequestParamDescr = getAssetName
        $newOperationRequestParamIsRequired = $TRUE
        $newOperationRequestParamDefaultValue = getAssetName
        $newOperationRequestParamType = "string"

        $newOperationRequestRepresentationContentType = "application/json"
        $newOperationRequestRepresentationSample = getAssetName

        $newOperationResponseDescription = getAssetName
        $newOperationResponseStatusCode = 1980785443;
        $newOperationResponseRepresentationContentType = getAssetName
        $newOperationResponseRepresentationSample = getAssetName

        #create parameters declared in UrlTemplate
        $rid = New-Object –TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementParameter
        $rid.Name = "rid"
        $rid.Description = "Resource identifier"
        $rid.Type = "string"

        $query = New-Object –TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementParameter
        $query.Name = "query"
        $query.Description = "Query string"
        $query.Type = "string"

        #create request
        $request = New-Object –TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementRequest
        $request.Description = "Create/update resource request"

        #create query parameters for the request
        $dummyQp = New-Object –TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementParameter
        $dummyQp.Name = $newOperationRequestParmName
        $dummyQp.Description = $newOperationRequestParamDescr
        $dummyQp.Type = $newOperationRequestParamType
        $dummyQp.Required = $newOperationRequestParamIsRequired
        $dummyQp.DefaultValue = $newOperationRequestParamDefaultValue
        $dummyQp.Values = @($newOperationRequestParamDefaultValue)
        $request.QueryParameters = @($dummyQp)

        #create headers for the request
        $header = New-Object –TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementParameter
        $header.Name = $newOperationRequestHeaderParamName
        $header.Description = $newOperationRequestHeaderParamDescr
        $header.DefaultValue = $newOperationRequestHeaderParamDefaultValue
        $header.Values = @($newOperationRequestHeaderParamDefaultValue)
        $header.Type = $newOperationRequestHeaderParamType
        $header.Required = $newOperationRequestHeaderParamIsRequired
        $request.Headers = @($header)

        #create request representation
        $requestRepresentation = New-Object –TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementRepresentation
        $requestRepresentation.ContentType = $newOperationRequestRepresentationContentType
        $requestRepresentation.Sample = $newOperationRequestRepresentationSample
        $request.Representations = @($requestRepresentation)

        #create response
        $response = New-Object –TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementResponse
        $response.StatusCode = $newOperationResponseStatusCode
        $response.Description = $newOperationResponseDescription

        #create response representation
        $responseRepresentation = New-Object –TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementRepresentation
        $responseRepresentation.ContentType = $newOperationResponseRepresentationContentType
        $responseRepresentation.Sample = $newOperationResponseRepresentationSample
        $response.Representations = @($responseRepresentation)

        $newOperation = New-AzureRMApiManagementOperation –Context $context –ApiId $api.ApiId –OperationId $newOperationId –Name $newOperationName `
         –Method $newOperationMethod –UrlTemplate $newperationUrlTemplate –Description $newOperationDescription –TemplateParameters @($rid, $query) –Request $request –Responses @($response)

        Assert-AreEqual $api.ApiId $newOperation.ApiId
        Assert-AreEqual $newOperationId $newOperation.OperationId
        Assert-AreEqual $newOperationName $newOperation.Name
        Assert-AreEqual $newOperationMethod $newOperation.Method
        Assert-AreEqual $newperationUrlTemplate $newOperation.UrlTemplate
        Assert-AreEqual $newOperationDescription $newOperation.Description

        Assert-NotNull $newOperation.TemplateParameters
        Assert-AreEqual 2 $newOperation.TemplateParameters.Count
        Assert-AreEqual $rid.Name $newOperation.TemplateParameters[0].Name
        Assert-AreEqual $rid.Description $newOperation.TemplateParameters[0].Description
        Assert-AreEqual $rid.Type $newOperation.TemplateParameters[0].Type
        Assert-AreEqual $query.Name $newOperation.TemplateParameters[1].Name
        Assert-AreEqual $query.Description $newOperation.TemplateParameters[1].Description
        Assert-AreEqual $query.Type $newOperation.TemplateParameters[1].Type

        Assert-NotNull $newOperation.Request
        Assert-AreEqual $request.Description $newOperation.Request.Description
        Assert-NotNull $newOperation.Request.QueryParameters
        Assert-AreEqual 1 $newOperation.Request.QueryParameters.Count
        Assert-AreEqual $dummyQp.Name $newOperation.Request.QueryParameters[0].Name
        Assert-AreEqual $dummyQp.Description $newOperation.Request.QueryParameters[0].Description
        Assert-AreEqual $dummyQp.Type $newOperation.Request.QueryParameters[0].Type
        Assert-AreEqual $dummyQp.Required $newOperation.Request.QueryParameters[0].Required
        Assert-AreEqual $dummyQp.DefaultValue $newOperation.Request.QueryParameters[0].DefaultValue
    
        Assert-AreEqual 1 $newOperation.Request.Headers.Count
        Assert-AreEqual $header.Name $newOperation.Request.Headers[0].Name
        Assert-AreEqual $header.Description $newOperation.Request.Headers[0].Description
        Assert-AreEqual $header.Type $newOperation.Request.Headers[0].Type
        Assert-AreEqual $header.Required $newOperation.Request.Headers[0].Required
        Assert-AreEqual $header.DefaultValue $newOperation.Request.Headers[0].DefaultValue

        Assert-NotNull $newOperation.Responses
        Assert-AreEqual 1 $newOperation.Responses.Count
        Assert-AreEqual $newOperationResponseStatusCode $newOperation.Responses[0].StatusCode
        Assert-AreEqual $newOperationResponseDescription $newOperation.Responses[0].Description
        Assert-NotNull $newOperation.Responses[0].Representations
        Assert-AreEqual 1 $newOperation.Responses[0].Representations.Count
        Assert-AreEqual $newOperationResponseRepresentationContentType $newOperation.Responses[0].Representations[0].ContentType
        Assert-AreEqual $newOperationResponseRepresentationSample $newOperation.Responses[0].Representations[0].Sample

        #change operation

        $newOperationName = getAssetName
        $newOperationMethod = "PUT"
        $newperationUrlTemplate = "/resource/{xrid}?q={xquery}"
        $newOperationDescription = getAssetName
        $newOperationRequestDescription = getAssetName

        $newOperationRequestHeaderParamName = getAssetName
        $newOperationRequestHeaderParamDescr = getAssetName
        $newOperationRequestHeaderParamIsRequired = $TRUE
        $newOperationRequestHeaderParamDefaultValue = getAssetName
        $newOperationRequestHeaderParamType = "string"

        $newOperationRequestParmName = getAssetName
        $newOperationRequestParamDescr = getAssetName
        $newOperationRequestParamIsRequired = $TRUE
        $newOperationRequestParamDefaultValue = getAssetName
        $newOperationRequestParamType = "string"

        $newOperationRequestRepresentationContentType = "application/json"
        $newOperationRequestRepresentationSample = getAssetName

        $newOperationResponseDescription = getAssetName
        $newOperationResponseStatusCode = 1980785443;
        $newOperationResponseRepresentationContentType = getAssetName
        $newOperationResponseRepresentationSample = getAssetName

        #create parameters declared in UrlTemplate
        $rid = New-Object –TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementParameter
        $rid.Name = "xrid"
        $rid.Description = "Resource identifier modified"
        $rid.Type = "string"

        $query = New-Object –TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementParameter
        $query.Name = "xquery"
        $query.Description = "Query string modified"
        $query.Type = "string"

        #create request
        $request = New-Object –TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementRequest
        $request.Description = "Create/update resource request modified"

        #create query parameters for the request
        $dummyQp = New-Object –TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementParameter
        $dummyQp.Name = $newOperationRequestParmName
        $dummyQp.Description = $newOperationRequestParamDescr
        $dummyQp.Type = $newOperationRequestParamType
        $dummyQp.Required = $newOperationRequestParamIsRequired
        $dummyQp.DefaultValue = $newOperationRequestParamDefaultValue
        $dummyQp.Values = @($newOperationRequestParamDefaultValue)
        $request.QueryParameters = @($dummyQp)

        #create headers for the request
        $header = New-Object –TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementParameter
        $header.Name = $newOperationRequestHeaderParamName
        $header.Description = $newOperationRequestHeaderParamDescr
        $header.DefaultValue = $newOperationRequestHeaderParamDefaultValue
        $header.Values = @($newOperationRequestHeaderParamDefaultValue)
        $header.Type = $newOperationRequestHeaderParamType
        $header.Required = $newOperationRequestHeaderParamIsRequired
        $request.Headers = @($header)

        #create request representation
        $requestRepresentation = New-Object –TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementRepresentation
        $requestRepresentation.ContentType = $newOperationRequestRepresentationContentType
        $requestRepresentation.Sample = $newOperationRequestRepresentationSample
        $request.Representations = @($requestRepresentation)

        #create response
        $response = New-Object –TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementResponse
        $response.StatusCode = $newOperationResponseStatusCode
        $response.Description = $newOperationResponseDescription

        #create response representation
        $responseRepresentation = New-Object –TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementRepresentation
        $responseRepresentation.ContentType = $newOperationResponseRepresentationContentType
        $responseRepresentation.Sample = $newOperationResponseRepresentationSample
        $response.Representations = @($responseRepresentation)

        $newOperation = Set-AzureRMApiManagementOperation –Context $context –ApiId $api.ApiId –OperationId $newOperationId –Name $newOperationName `
         –Method $newOperationMethod –UrlTemplate $newperationUrlTemplate –Description $newOperationDescription –TemplateParameters @($rid, $query) –Request $request –Responses @($response) -PassThru

        Assert-AreEqual $api.ApiId $newOperation.ApiId
        Assert-AreEqual $newOperationId $newOperation.OperationId
        Assert-AreEqual $newOperationName $newOperation.Name
        Assert-AreEqual $newOperationMethod $newOperation.Method
        Assert-AreEqual $newperationUrlTemplate $newOperation.UrlTemplate
        Assert-AreEqual $newOperationDescription $newOperation.Description

        Assert-NotNull $newOperation.TemplateParameters
        Assert-AreEqual 2 $newOperation.TemplateParameters.Count
        Assert-AreEqual $rid.Name $newOperation.TemplateParameters[0].Name
        Assert-AreEqual $rid.Description $newOperation.TemplateParameters[0].Description
        Assert-AreEqual $rid.Type $newOperation.TemplateParameters[0].Type
        Assert-AreEqual $query.Name $newOperation.TemplateParameters[1].Name
        Assert-AreEqual $query.Description $newOperation.TemplateParameters[1].Description
        Assert-AreEqual $query.Type $newOperation.TemplateParameters[1].Type

        Assert-NotNull $newOperation.Request
        Assert-AreEqual $request.Description $newOperation.Request.Description
        Assert-NotNull $newOperation.Request.QueryParameters
        Assert-AreEqual 1 $newOperation.Request.QueryParameters.Count
        Assert-AreEqual $dummyQp.Name $newOperation.Request.QueryParameters[0].Name
        Assert-AreEqual $dummyQp.Description $newOperation.Request.QueryParameters[0].Description
        Assert-AreEqual $dummyQp.Type $newOperation.Request.QueryParameters[0].Type
        Assert-AreEqual $dummyQp.Required $newOperation.Request.QueryParameters[0].Required
        Assert-AreEqual $dummyQp.DefaultValue $newOperation.Request.QueryParameters[0].DefaultValue
    
        Assert-AreEqual 1 $newOperation.Request.Headers.Count
        Assert-AreEqual $header.Name $newOperation.Request.Headers[0].Name
        Assert-AreEqual $header.Description $newOperation.Request.Headers[0].Description
        Assert-AreEqual $header.Type $newOperation.Request.Headers[0].Type
        Assert-AreEqual $header.Required $newOperation.Request.Headers[0].Required
        Assert-AreEqual $header.DefaultValue $newOperation.Request.Headers[0].DefaultValue

        Assert-NotNull $newOperation.Responses
        Assert-AreEqual 1 $newOperation.Responses.Count
        Assert-AreEqual $newOperationResponseStatusCode $newOperation.Responses[0].StatusCode
        Assert-AreEqual $newOperationResponseDescription $newOperation.Responses[0].Description
        Assert-NotNull $newOperation.Responses[0].Representations
        Assert-AreEqual 1 $newOperation.Responses[0].Representations.Count
        Assert-AreEqual $newOperationResponseRepresentationContentType $newOperation.Responses[0].Representations[0].ContentType
        Assert-AreEqual $newOperationResponseRepresentationSample $newOperation.Responses[0].Representations[0].Sample
    }
    finally
    {
        #remove created operation
        $removed = Remove-AzureRMApiManagementOperation -Context $context -ApiId $api.ApiId -OperationId $newOperationId -Force -PassThru
        Assert-True {$removed}

        $operation = $null
        try
        {
            # check it was removed
            $operation = Get-AzureRMApiManagementOperation -Context $context -ApiId $api.ApiId -OperationId $newOperationId
        }
        catch
        {
        }

        Assert-Null $operation
    }
}

<#
.SYNOPSIS
Tests CRUD operations of Product.
#>
function Product-CrudTest
{
Param($resourceGroupName, $serviceName)

    $context = New-AzureRMApiManagementContext -ResourceGroupName $resourceGroupName -ServiceName $serviceName

    # get all products
    $products = Get-AzureRMApiManagementProduct -Context $context

    # there should be 2 products
    Assert-AreEqual 2 $products.Count

    $found = 0
    for ($i = 0; $i -lt $products.Count; $i++)
    {
        Assert-NotNull $products[$i].ProductId
        Assert-NotNull $products[$i].Description
        Assert-AreEqual Published $products[$i].State
        
        if($products[$i].Title -eq 'Starter')
        {
            $found += 1;
        }

        if($products[$i].Title -eq 'Unlimited')
        {
            $found += 1;
        }
    }
    Assert-AreEqual 2 $found

    #create new product
    $productId = getAssetName
    try
    {
        $productName = getAssetName
        $productApprovalRequired = $TRUE
        $productDescription = getAssetName
        $notificationPeriod = "M2"
        $productState = "Published"
        $subscriptionPeriod = "Y1"
        $productSubscriptionRequired = $TRUE
        $productSubscriptionsLimit = 10
        $productTerms = getAssetName

        $newProduct = New-AzureRMApiManagementProduct -Context $context –ProductId $productId –Title $productName –Description $productDescription `
            –LegalTerms $productTerms –NotificationPeriod $notificationPeriod –SubscriptionPeriod $subscriptionPeriod –SubscriptionRequired $productSubscriptionRequired `
            –ApprovalRequired $productApprovalRequired –State $productState -SubscriptionsLimit $productSubscriptionsLimit

        Assert-AreEqual $productId $newProduct.ProductId 
        Assert-AreEqual $productName $newProduct.Title
        Assert-AreEqual $productApprovalRequired $newProduct.ApprovalRequired
        Assert-AreEqual $productDescription $newProduct.Description
        Assert-AreEqual $notificationPeriod $newProduct.NotificationPeriod
        Assert-AreEqual "NotPublished" $newProduct.State #product must contain at least one api to be published
        Assert-AreEqual $subscriptionPeriod $newProduct.SubscriptionPeriod
        Assert-AreEqual $productSubscriptionRequired $newProduct.SubscriptionRequired
        Assert-AreEqual $productSubscriptionsLimit $newProduct.SubscriptionsLimit
        Assert-AreEqual $productTerms $newProduct.LegalTerms

        #add api to product
        $apis = Get-AzureRMApiManagementApi -Context $context -ProductId $productId
        Assert-AreEqual 0 $apis.Count

        Get-AzureRMApiManagementApi -Context $context | Add-AzureRMApiManagementApiToProduct -Context $context -ProductId $productId

        $apis = Get-AzureRMApiManagementApi -Context $context -ProductId $productId
        Assert-AreEqual 1 $apis.Count

        #modify product
        $productName = getAssetName
        $productApprovalRequired = $FALSE
        $productDescription = getAssetName
        $notificationPeriod = "M5"
        $productState = "Published"
        $subscriptionPeriod = "Y2"
        $productSubscriptionRequired = $TRUE
        $productSubscriptionsLimit = 20
        $productTerms = getAssetName

        $newProduct = Set-AzureRMApiManagementProduct -Context $context –ProductId $productId –Title $productName –Description $productDescription `
            –LegalTerms $productTerms –NotificationPeriod $notificationPeriod –SubscriptionPeriod $subscriptionPeriod -ApprovalRequired $productApprovalRequired `
             –SubscriptionRequired $TRUE –State $productState -SubscriptionsLimit $productSubscriptionsLimit -PassThru

        Assert-AreEqual $productId $newProduct.ProductId 
        Assert-AreEqual $productName $newProduct.Title
        Assert-AreEqual $productApprovalRequired $newProduct.ApprovalRequired
        Assert-AreEqual $productDescription $newProduct.Description
        Assert-AreEqual $notificationPeriod $newProduct.NotificationPeriod
        Assert-AreEqual $productState $newProduct.State
        Assert-AreEqual $subscriptionPeriod $newProduct.SubscriptionPeriod
        Assert-AreEqual $productSubscriptionRequired $newProduct.SubscriptionRequired
        Assert-AreEqual $productSubscriptionsLimit $newProduct.SubscriptionsLimit
        Assert-AreEqual $productTerms $newProduct.LegalTerms

        #remove api from product
        Get-AzureRMApiManagementApi -Context $context | Remove-AzureRMApiManagementApiFromProduct -Context $context -ProductId $productId

        $apis = Get-AzureRMApiManagementApi -Context $context -ProductId $productId
        Assert-AreEqual 0 $apis.Count
    } 
    finally
    {
        # remove created product
        $removed = Remove-AzureRMApiManagementProduct -Context $context -ProductId $productId -DeleteSubscriptions -PassThru -Force
        Assert-True {$removed}
    }
}

<#
.SYNOPSIS
Tests CRUD operations of Subscription.
#>
function Subscription-CrudTest
{
Param($resourceGroupName, $serviceName)

    $context = New-AzureRMApiManagementContext -ResourceGroupName $resourceGroupName -ServiceName $serviceName

    # get all subscriptions
    $subs = Get-AzureRMApiManagementSubscription -Context $context

    Assert-AreEqual 2 $subs.Count
    for($i = 0; $i -lt $subs.Count; $i++)
    {
        Assert-NotNull $subs[$i]
        Assert-NotNull $subs[$i].UserId
        Assert-NotNull $subs[$i].SubscriptionId
        Assert-NotNull $subs[$i].ProductId
        Assert-NotNull $subs[$i].State
        Assert-NotNull $subs[$i].CreatedDate
        Assert-NotNull $subs[$i].PrimaryKey
        Assert-NotNull $subs[$i].SecondaryKey

        # get by id
        $sub = Get-AzureRMApiManagementSubscription -Context $context -SubscriptionId $subs[$i].SubscriptionId

        Assert-AreEqual $subs[$i].SubscriptionId $sub.SubscriptionId
        Assert-AreEqual $subs[$i].UserId $sub.UserId
        Assert-AreEqual $subs[$i].ProductId $sub.ProductId
        Assert-AreEqual $subs[$i].State $sub.State
        Assert-AreEqual $subs[$i].CreatedDate $sub.CreatedDate
        Assert-AreEqual $subs[$i].PrimaryKey $sub.PrimaryKey
        Assert-AreEqual $subs[$i].SecondaryKey $sub.SecondaryKey
    }

    # update product to accept unlimited number or subscriptions
    Set-AzureRMApiManagementProduct -Context $context -ProductId $subs[0].ProductId -SubscriptionsLimit 100

    # add new subscription
    $newSubscriptionId = getAssetName
    try
    {
        $newSubscriptionName = getAssetName
        $newSubscriptionPk = getAssetName
        $newSubscriptionSk = getAssetName
        $newSubscriptionState = "Active"

        $sub = New-AzureRMApiManagementSubscription -Context $context -SubscriptionId $newSubscriptionId -UserId $subs[0].UserId `
            -ProductId $subs[0].ProductId -Name $newSubscriptionName -PrimaryKey $newSubscriptionPk -SecondaryKey $newSubscriptionSk `
            -State $newSubscriptionState

        Assert-AreEqual $newSubscriptionId $sub.SubscriptionId
        Assert-AreEqual $newSubscriptionName $sub.Name
        Assert-AreEqual $newSubscriptionPk $sub.PrimaryKey
        Assert-AreEqual $newSubscriptionSk $sub.SecondaryKey
        Assert-AreEqual $newSubscriptionState $sub.State

        # update subscription
        $patchedName = getAssetName
        $patchedPk = getAssetName
        $patchedSk = getAssetName
        $patchedExpirationDate = [DateTime]::Parse('2025-7-20')

        $sub = Set-AzureRMApiManagementSubscription -Context $context -SubscriptionId $newSubscriptionId -Name $patchedName `
            -PrimaryKey $patchedPk -SecondaryKey $patchedSk -ExpiresOn $patchedExpirationDate -PassThru

        Assert-AreEqual $newSubscriptionId $sub.SubscriptionId
        Assert-AreEqual $patchedName $sub.Name
        Assert-AreEqual $patchedPk $sub.PrimaryKey
        Assert-AreEqual $patchedSk $sub.SecondaryKey
        Assert-AreEqual $newSubscriptionState $sub.State
        Assert-AreEqual $patchedExpirationDate $sub.ExpirationDate
    }
    finally
    {
        # remove created subscription
        $removed = Remove-AzureRMApiManagementSubscription -Context $context -SubscriptionId $newSubscriptionId -Force -PassThru
        Assert-True {$removed}

        $sub = $null
        try
        {
            # check it was removed
            $sub = Get-AzureRMApiManagementSubscripiton -Context $context -SubscriptionId $newSubscriptionId
        }
        catch
        {
        }

        Assert-Null $sub
    }
}

<#
.SYNOPSIS
Tests CRUD operations of User.
#>
function User-CrudTest
{
Param($resourceGroupName, $serviceName)

    $context = New-AzureRMApiManagementContext -ResourceGroupName $resourceGroupName -ServiceName $serviceName

    # get all users
    $users = Get-AzureRMApiManagementUser -Context $context

    Assert-AreEqual 1 $users.Count
    Assert-NotNull $users[0].UserId
    Assert-NotNull $users[0].FirstName
    Assert-NotNull $users[0].LastName
    Assert-NotNull $users[0].Email
    Assert-NotNull $users[0].State
    Assert-NotNull $users[0].RegistrationDate

    # get by id
    $user = Get-AzureRMApiManagementUser -Context $context -UserId $users[0].UserId

    Assert-AreEqual $users[0].UserId $user.UserId
    Assert-AreEqual $users[0].FirstName $user.FirstName
    Assert-AreEqual $users[0].LastName $user.LastName
    Assert-AreEqual $users[0].Email $user.Email
    Assert-AreEqual $users[0].State $user.State
    Assert-AreEqual $users[0].RegistrationDate $user.RegistrationDate

    # create user
    $userId = getAssetName
    try
    {
        $userEmail = "contoso@microsoft.com"
        $userFirstName = getAssetName
        $userLastName = getAssetName
        $userPassword = getAssetName
        $userNote = getAssetName
        $userSate = "Active"

        $user = New-AzureRMApiManagementUser -Context $context -UserId $userId -FirstName $userFirstName -LastName $userLastName `
            -Password $userPassword -State $userSate -Note $userNote -Email $userEmail

        Assert-AreEqual $userId $user.UserId
        Assert-AreEqual $userEmail $user.Email
        Assert-AreEqual $userFirstName $user.FirstName
        Assert-AreEqual $userLastName $user.LastName
        Assert-AreEqual $userNote $user.Note
        Assert-AreEqual $userSate $user.State

        #update user
        $userEmail = "changed.contoso@microsoft.com"
        $userFirstName = getAssetName
        $userLastName = getAssetName
        $userPassword = getAssetName
        $userNote = getAssetName
        $userSate = "Active"

        $user = Set-AzureRMApiManagementUser -Context $context -UserId $userId -FirstName $userFirstName -LastName $userLastName `
            -Password $userPassword -State $userSate -Note $userNote -PassThru -Email $userEmail

        Assert-AreEqual $userId $user.UserId
        Assert-AreEqual $userEmail $user.Email
        Assert-AreEqual $userFirstName $user.FirstName
        Assert-AreEqual $userLastName $user.LastName
        Assert-AreEqual $userNote $user.Note
        Assert-AreEqual $userSate $user.State

        #generate SSO URL for the user
        $ssoUrl = Get-AzureRMApiManagementUserSsoUrl -Context $context -UserId $userId

        Assert-NotNull $ssoUrl
        Assert-AreEqual $true [System.Uri]::IsWellFormedUriString($ssoUrl, 'Absolute')
    }
    finally
    {
        # remove created user
        $removed = Remove-AzureRMApiManagementUser -Context $context -UserId $userId -DeleteSubscriptions -Force -PassThru
        Assert-True {$removed}

        $user = $null
        try
        {
            # check it was removed
            $user = Get-AzureRMApiManagementUser -Context $context -UserId $userId
        }
        catch
        {
        }

        Assert-Null $user
    }
}

<#
.SYNOPSIS
Tests CRUD operations of Group.
#>
function Group-CrudTest
{
Param($resourceGroupName, $serviceName)

    $context = New-AzureRMApiManagementContext -ResourceGroupName $resourceGroupName -ServiceName $serviceName

    # get all groups
    $groups = Get-AzureRMApiManagementGroup -Context $context

    Assert-AreEqual 3 $groups.Count
    for($i = 0; $i -lt 3; $i++)
    {
        Assert-NotNull $groups[$i].GroupId
        Assert-NotNull $groups[$i].Name
        Assert-NotNull $groups[$i].Description
        Assert-NotNull $groups[$i].System
        Assert-NotNull $groups[$i].Type
        
        # get by id
        $group = Get-AzureRMApiManagementGroup -Context $context -GroupId $groups[$i].GroupId

        Assert-AreEqual $group.GroupId $groups[$i].GroupId
        Assert-AreEqual $group.Name $groups[$i].Name
        Assert-AreEqual $group.Description $groups[$i].Description
        Assert-AreEqual $group.System $groups[$i].System
        Assert-AreEqual $group.Type $groups[$i].Type
    }

    # create group with default parameters
    $groupId = getAssetName
    try
    {
        $newGroupName = getAssetName
        $newGroupDescription = getAssetName

        $group = New-AzureRMApiManagementGroup -GroupId $groupId -Context $context -Name $newGroupName -Description $newGroupDescription

        Assert-AreEqual $groupId $group.GroupId
        Assert-AreEqual $newGroupName $group.Name
        Assert-AreEqual $newGroupDescription $group.Description
        Assert-AreEqual $false $group.System
        Assert-AreEqual 'Custom' $group.Type

        # update group
        $newGroupName = getAssetName
        $newGroupDescription = getAssetName

        $group = Set-AzureRMApiManagementGroup -Context $context -GroupId $groupId -Name $newGroupName -Description $newGroupDescription -PassThru

        Assert-AreEqual $groupId $group.GroupId
        Assert-AreEqual $newGroupName $group.Name
        Assert-AreEqual $newGroupDescription $group.Description
        Assert-AreEqual $false $group.System
        Assert-AreEqual 'Custom' $group.Type

        # add Product to Group
        $product = Get-AzureRMApiManagementProduct -Context $context | Select -First 1
        Add-AzureRMApiManagementProductToGroup -Context $context -GroupId $groupId -ProductId $product.ProductId

        #check group products
        $groups = Get-AzureRMApiManagementGroup -Context $context -ProductId $product.ProductId
        Assert-AreEqual 4 $groups.Count

        # remove Product to Group
        Remove-AzureRMApiManagementProductFromGroup -Context $context -GroupId $groupId -ProductId $product.ProductId

        #check group products
        $groups = Get-AzureRMApiManagementGroup -Context $context -ProductId $product.ProductId
        Assert-AreEqual 3 $groups.Count

        # add User to Group
        $user = Get-AzureRMApiManagementUser -Context $context | Select -First 1
        Add-AzureRMApiManagementUserToGroup -Context $context -GroupId $groupId -UserId $user.UserId

        $groups = Get-AzureRMApiManagementGroup -Context $context -UserId $user.UserId
        Assert-AreEqual 3 $groups.Count

        #remove user from group
        Remove-AzureRMApiManagementUserFromGroup -Context $context -GroupId $groupId -UserId $user.UserId
        $groups = Get-AzureRMApiManagementGroup -Context $context -UserId $user.UserId
        Assert-AreEqual 2 $groups.Count
    }
    finally
    {
        # remove created group
        $removed = Remove-AzureRMApiManagementGroup -Context $context -GroupId $groupId -Force -PassThru
        Assert-True {$removed}

        $group = $null
        try
        {
            # check it was removed
            $group = Get-AzureRMApiManagementGroup -Context $context -GroupId $groupId
        }
        catch
        {
        }

        Assert-Null $group
    }
}

<#
.SYNOPSIS
Tests CRUD operations of Policy.
#>
function Policy-CrudTest
{
Param($resourceGroupName, $serviceName)

    # load from file get to pipeline scenarios

    $tenantValidPath = "./Resources/TenantValidPolicy.xml"
    $productValidPath = "./Resources/ProductValidPolicy.xml"
    $apiValidPath = "./Resources/ApiValidPolicy.xml"
    $operationValidPath = "./Resources/OperationValidPolicy.xml"

    $context = New-AzureRMApiManagementContext -ResourceGroupName $resourceGroupName -ServiceName $serviceName

    # test tenant policy
    try
    {
        $set = Set-AzureRMApiManagementPolicy -Context $context  -PolicyFilePath $tenantValidPath -PassThru
        Assert-AreEqual $true $set

        $policy = Get-AzureRMApiManagementPolicy -Context $context 
        Assert-NotNull $policy
        Assert-True {$policy -like '*<find-and-replace from="aaa" to="BBB" />*'}
    }
    finally
    {
        $removed = Remove-AzureRMApiManagementPolicy -Context $context -PassThru -Force
        Assert-AreEqual $true $removed

        $policy = Get-AzureRMApiManagementPolicy -Context $context 
        Assert-Null $policy
    }

    # test product policy
    $product = Get-AzureRMApiManagementProduct -Context $context -Title 'Unlimited' | Select -First 1
    try
    {
        $set = Set-AzureRMApiManagementPolicy -Context $context  -PolicyFilePath $productValidPath -ProductId $product.ProductId -PassThru
        Assert-AreEqual $true $set

        $policy = Get-AzureRMApiManagementPolicy -Context $context  -ProductId $product.ProductId
        Assert-NotNull $policy
        Assert-True {$policy -like '*<rate-limit calls="5" renewal-period="60" />*'}
    }
    finally
    {
        $removed = Remove-AzureRMApiManagementPolicy -Context $context -ProductId $product.ProductId -PassThru -Force
        Assert-AreEqual $true $removed

        $policy = Get-AzureRMApiManagementPolicy -Context $context  -ProductId $product.ProductId
        Assert-Null $policy
    }

    # test api policy
    $api = Get-AzureRMApiManagementApi -Context $context | Select -First 1
    try
    {
        $set = Set-AzureRMApiManagementPolicy -Context $context  -PolicyFilePath $apiValidPath -ApiId $api.ApiId -PassThru
        Assert-AreEqual $true $set

        $policy = Get-AzureRMApiManagementPolicy -Context $context  -ApiId $api.ApiId
        Assert-NotNull $policy
        Assert-True {$policy -like '*<cache-lookup vary-by-developer="false" vary-by-developer-groups="false" downstream-caching-type="none">*'}
    }
    finally
    {
        $removed = Remove-AzureRMApiManagementPolicy -Context $context -ApiId $api.ApiId -PassThru -Force
        Assert-AreEqual $true $removed

        $policy = Get-AzureRMApiManagementPolicy -Context $context  -ApiId $api.ApiId
        Assert-Null $policy
    }

    # test operation policy
    $api = Get-AzureRMApiManagementApi -Context $context | Select -First 1
    $operation = Get-AzureRMApiManagementOperation -Context $context -ApiId $api.ApiId | Select -First 1
    try
    {
        $set = Set-AzureRMApiManagementPolicy -Context $context  -PolicyFilePath $operationValidPath -ApiId $api.ApiId `
            -OperationId $operation.OperationId -PassThru
        Assert-AreEqual $true $set

        $policy = Get-AzureRMApiManagementPolicy -Context $context  -ApiId $api.ApiId -OperationId $operation.OperationId
        Assert-NotNull $policy
        Assert-True {$policy -like '*<rewrite-uri template="/resource" />*'}
    }
    finally
    {
        $removed = Remove-AzureRMApiManagementPolicy -Context $context -ApiId $api.ApiId -OperationId $operation.OperationId -PassThru -Force
        Assert-AreEqual $true $removed

        $policy = Get-AzureRMApiManagementPolicy -Context $context  -ApiId $api.ApiId -OperationId $operation.OperationId
        Assert-Null $policy
    }

    # load from string save to file scenarios

    # test tenant policy
    $tenantValid = '<policies><inbound><find-and-replace from="aaa" to="BBB" /><set-header name="ETag" exists-action="skip"><value>bbyby</value><!-- for multiple headers with the same name add additional value elements --></set-header><set-query-parameter name="additional" exists-action="append"><value>xxbbcczc</value><!-- for multiple parameters with the same name add additional value elements --></set-query-parameter><cross-domain /></inbound><outbound /></policies>'
    try
    {
        $set = Set-AzureRMApiManagementPolicy -Context $context  -Policy $tenantValid -PassThru
        Assert-AreEqual $true $set

        Get-AzureRMApiManagementPolicy -Context $context  -SaveAs 'TenantPolicy.xml' -Force
        $exists = [System.IO.File]::Exists('TenantPolicy.xml')
        $policy = gc 'TenantPolicy.xml'
        Assert-True {$policy -like '*<find-and-replace from="aaa" to="BBB" />*'}
    }
    finally
    {
        $removed = Remove-AzureRMApiManagementPolicy -Context $context -PassThru -Force
        Assert-AreEqual $true $removed

        $policy = Get-AzureRMApiManagementPolicy -Context $context 
        Assert-Null $policy
    }

    # test product policy
    $productValid = '<policies><inbound><rate-limit calls="5" renewal-period="60" /><quota calls="100" renewal-period="604800" /><base /></inbound><outbound><base /></outbound></policies>'
    $product = Get-AzureRMApiManagementProduct -Context $context -Title 'Unlimited' | Select -First 1
    try
    {
        $set = Set-AzureRMApiManagementPolicy -Context $context  -Policy $productValid -ProductId $product.ProductId -PassThru
        Assert-AreEqual $true $set

        Get-AzureRMApiManagementPolicy -Context $context  -ProductId $product.ProductId -SaveAs 'ProductPolicy.xml' -Force
        $exists = [System.IO.File]::Exists('ProductPolicy.xml')
        $policy = gc 'ProductPolicy.xml'
        Assert-True {$policy -like '*<rate-limit calls="5" renewal-period="60" />*'}
    }
    finally
    {
        $removed = Remove-AzureRMApiManagementPolicy -Context $context -ProductId $product.ProductId -PassThru -Force
        Assert-AreEqual $true $removed

        $policy = Get-AzureRMApiManagementPolicy -Context $context  -ProductId $product.ProductId
        Assert-Null $policy

        try
        {
            rm 'ProductPolicy.xml'
        }
        catch{}
    }

    # test api policy
    $apiValid = '<policies><inbound><base /><cache-lookup vary-by-developer="false" vary-by-developer-groups="false" downstream-caching-type="none"><vary-by-query-parameter>version</vary-by-query-parameter><vary-by-header>Accept</vary-by-header><vary-by-header>Accept-Charset</vary-by-header></cache-lookup></inbound><outbound><cache-store duration="10" /><base /></outbound></policies>'
    $api = Get-AzureRMApiManagementApi -Context $context | Select -First 1
    try
    {
        $set = Set-AzureRMApiManagementPolicy -Context $context  -Policy $apiValid -ApiId $api.ApiId -PassThru
        Assert-AreEqual $true $set

        $policy = Get-AzureRMApiManagementPolicy -Context $context  -ApiId $api.ApiId -SaveAs 'ApiPolicy.xml'
        $exists = [System.IO.File]::Exists('ApiPolicy.xml')
        $policy = gc 'ApiPolicy.xml'
        Assert-True {$policy -like '*<cache-lookup vary-by-developer="false" vary-by-developer-groups="false" downstream-caching-type="none">*'}
    }
    finally
    {
        $removed = Remove-AzureRMApiManagementPolicy -Context $context -ApiId $api.ApiId -PassThru -Force
        Assert-AreEqual $true $removed

        $policy = Get-AzureRMApiManagementPolicy -Context $context  -ApiId $api.ApiId
        Assert-Null $policy

        try
        {
            rm 'ApiPolicy.xml'
        }
        catch{}
    }

    # test operation policy
    $operationValid = '<policies><inbound><base /><rewrite-uri template="/resource" /></inbound><outbound><base /></outbound></policies>'
    $api = Get-AzureRMApiManagementApi -Context $context | Select -First 1
    $operation = Get-AzureRMApiManagementOperation -Context $context -ApiId $api.ApiId | Select -First 1
    try
    {
        $set = Set-AzureRMApiManagementPolicy -Context $context  -Policy $operationValid -ApiId $api.ApiId `
            -OperationId $operation.OperationId -PassThru
        Assert-AreEqual $true $set

        $policy = Get-AzureRMApiManagementPolicy -Context $context  -ApiId $api.ApiId -OperationId $operation.OperationId `
            -SaveAs 'OperationPolicy.xml'
        $exists = [System.IO.File]::Exists('OperationPolicy.xml')
        $policy = gc 'OperationPolicy.xml'
        Assert-True {$policy -like '*<rewrite-uri template="/resource" />*'}
    }
    finally
    {
        $removed = Remove-AzureRMApiManagementPolicy -Context $context -ApiId $api.ApiId -OperationId $operation.OperationId -PassThru -Force
        Assert-AreEqual $true $removed

        $policy = Get-AzureRMApiManagementPolicy -Context $context  -ApiId $api.ApiId -OperationId $operation.OperationId
        Assert-Null $policy

        try
        {
            rm 'OperationPolicy.xml'
        }
        catch{}
    }
}

<#
.SYNOPSIS
Tests CRUD operations of Certificate.
#>
function Certificate-CrudTest
{
Param($resourceGroupName, $serviceName)

    $context = New-AzureRMApiManagementContext -ResourceGroupName $resourceGroupName -ServiceName $serviceName

    # get all certificates
    $certificates = Get-AzureRMApiManagementCertificate -Context $context

    Assert-AreEqual 0 $certificates.Count

    $certPath = './Resources/testcertificate.pfx'
    $certPassword = 'powershelltest'
    $certThumbprint = '51A702569BADEDB90A75141B070F2D4B5DDFA447'
    $certSubject = 'CN=ailn.redmond.corp.microsoft.com'

    $certId = getAssetName
    try
    {
        # upload certificate
        $cert = New-AzureRMApiManagementCertificate -Context $context -CertificateId $certId -PfxFilePath $certPath -PfxPassword $certPassword

        Assert-AreEqual $certId $cert.CertificateId
        Assert-AreEqual $certThumbprint $cert.Thumbprint
        Assert-AreEqual $certSubject $cert.Subject

        # get certificate
        $cert = Get-AzureRMApiManagementCertificate -Context $context -CertificateId $certId

        Assert-AreEqual $certId $cert.CertificateId
        Assert-AreEqual $certThumbprint $cert.Thumbprint
        Assert-AreEqual $certSubject $cert.Subject

        # update certificate
        $cert = Set-AzureRMApiManagementCertificate -Context $context -CertificateId $certId -PfxFilePath $certPath -PfxPassword $certPassword -PassThru

        Assert-AreEqual $certId $cert.CertificateId
        Assert-AreEqual $certThumbprint $cert.Thumbprint
        Assert-AreEqual $certSubject $cert.Subject

        # list certificates
        $certificates = Get-AzureRMApiManagementCertificate -Context $context
        Assert-AreEqual 1 $certificates.Count

        Assert-AreEqual $certId $certificates[0].CertificateId
        Assert-AreEqual $certThumbprint $certificates[0].Thumbprint
        Assert-AreEqual $certSubject $certificates[0].Subject
    }
    finally
    {
        # remove uploaded certificate
        $removed = Remove-AzureRMApiManagementCertificate -Context $context -CertificateId $certId -Force -PassThru
        Assert-True {$removed}

        $cert = $null
        try
        {
            # check it was removed
            $cert = Get-AzureRMApiManagementCertificate -Context $context -CertificateId $certId
        }
        catch
        {
        }

        Assert-Null $cert
    }
}

<#
.SYNOPSIS
Tests CRUD operations of AuthorizationServer.
#>
function AuthorizationServer-CrudTest
{
Param($resourceGroupName, $serviceName)

    $context = New-AzureRMApiManagementContext -ResourceGroupName $resourceGroupName -ServiceName $serviceName

    # get all authoriaztion servers
    $servers = Get-AzureRMApiManagementAuthorizationServer -Context $context

    Assert-AreEqual 0 $servers.Count

    # create server
    $serverId = getAssetName
    try
    {
        $name = getAssetName
        $defaultScope = getAssetName
        $authorizationEndpoint = 'https://contoso.com/auth'
        $tokenEndpoint = 'https://contoso.com/token'
        $clientRegistrationEndpoint = 'https://contoso.com/clients/reg'
        $grantTypes = @('AuthorizationCode', 'Implicit', 'ResourceOwnerPassword')
        $authorizationMethods = @('Post', 'Get')
        $bearerTokenSendingMethods = @('AuthorizationHeader', 'Query')
        $clientId = getAssetName
        $description = getAssetName
        $clientAuthenticationMethods = @('Basic')
        $clientSecret = getAssetName
        $resourceOwnerPassword = getAssetName
        $resourceOwnerUsername = getAssetName
        $supportState = $true
        $tokenBodyParameters = @{'tokenname'='tokenvalue'}

        $server = New-AzureRMApiManagementAuthorizationServer -Context $context -ServerId $serverId -Name $name -Description $description `
            -ClientRegistrationPageUrl $clientRegistrationEndpoint -AuthorizationEndpointUrl $authorizationEndpoint `
            -TokenEndpointUrl $tokenEndpoint -ClientId $clientId -ClientSecret $clientSecret -AuthorizationRequestMethods $authorizationMethods `
            -GrantTypes $grantTypes -ClientAuthenticationMethods $clientAuthenticationMethods -TokenBodyParameters $tokenBodyParameters `
            -SupportState $supportState -DefaultScope $defaultScope -AccessTokenSendingMethods $bearerTokenSendingMethods `
            -ResourceOwnerUsername $resourceOwnerUsername -ResourceOwnerPassword $resourceOwnerPassword

        Assert-AreEqual $serverId $server.ServerId
        Assert-AreEqual $name $server.Name
        Assert-AreEqual $defaultScope $server.DefaultScope
        Assert-AreEqual $authorizationEndpoint $server.AuthorizationEndpointUrl
        Assert-AreEqual $tokenEndpoint $server.TokenEndpointUrl
        Assert-AreEqual $clientRegistrationEndpoint $server.ClientRegistrationPageUrl
        Assert-AreEqual $grantTypes.Count $server.GrantTypes.Count
        Assert-AreEqual $grantTypes[0] $server.GrantTypes[0]
        Assert-AreEqual $grantTypes[1] $server.GrantTypes[1]
        Assert-AreEqual $grantTypes[2] $server.GrantTypes[2]
        Assert-AreEqual $authorizationMethods.Count $server.AuthorizationRequestMethods.Count
        Assert-AreEqual $authorizationMethods[0] $server.AuthorizationRequestMethods[0]
        Assert-AreEqual $authorizationMethods[1] $server.AuthorizationRequestMethods[1]
        Assert-AreEqual $bearerTokenSendingMethods.Count $server.AccessTokenSendingMethods.Count
        Assert-AreEqual $bearerTokenSendingMethods[0] $server.AccessTokenSendingMethods[0]
        Assert-AreEqual $bearerTokenSendingMethods[1] $server.AccessTokenSendingMethods[1]
        Assert-AreEqual $clientId $server.ClientId
        Assert-AreEqual $description $server.Description
        Assert-AreEqual $clientAuthenticationMethods.Count $server.ClientAuthenticationMethods.Count
        Assert-AreEqual $clientAuthenticationMethods[0] $server.ClientAuthenticationMethods[0]
        Assert-AreEqual $clientSecret $server.ClientSecret
        Assert-AreEqual $resourceOwnerPassword $server.ResourceOwnerPassword
        Assert-AreEqual $resourceOwnerUsername $server.ResourceOwnerUsername
        Assert-AreEqual $supportState $server.SupportState
        Assert-AreEqual $tokenBodyParameters.Count $server.TokenBodyParameters.Count

        $server = Get-AzureRMApiManagementAuthorizationServer -Context $context -ServerId $serverId

        Assert-AreEqual $serverId $server.ServerId
        Assert-AreEqual $name $server.Name
        Assert-AreEqual $defaultScope $server.DefaultScope
        Assert-AreEqual $authorizationEndpoint $server.AuthorizationEndpointUrl
        Assert-AreEqual $tokenEndpoint $server.TokenEndpointUrl
        Assert-AreEqual $clientRegistrationEndpoint $server.ClientRegistrationPageUrl
        Assert-AreEqual $grantTypes.Count $server.GrantTypes.Count
        Assert-AreEqual $grantTypes[0] $server.GrantTypes[0]
        Assert-AreEqual $grantTypes[1] $server.GrantTypes[1]
        Assert-AreEqual $grantTypes[2] $server.GrantTypes[2]
        Assert-AreEqual $authorizationMethods.Count $server.AuthorizationRequestMethods.Count
        Assert-AreEqual $authorizationMethods[0] $server.AuthorizationRequestMethods[0]
        Assert-AreEqual $authorizationMethods[1] $server.AuthorizationRequestMethods[1]
        Assert-AreEqual $bearerTokenSendingMethods.Count $server.AccessTokenSendingMethods.Count
        Assert-AreEqual $bearerTokenSendingMethods[0] $server.AccessTokenSendingMethods[0]
        Assert-AreEqual $bearerTokenSendingMethods[1] $server.AccessTokenSendingMethods[1]
        Assert-AreEqual $clientId $server.ClientId
        Assert-AreEqual $description $server.Description
        Assert-AreEqual $clientAuthenticationMethods.Count $server.ClientAuthenticationMethods.Count
        Assert-AreEqual $clientAuthenticationMethods[0] $server.ClientAuthenticationMethods[0]
        Assert-AreEqual $clientSecret $server.ClientSecret
        Assert-AreEqual $resourceOwnerPassword $server.ResourceOwnerPassword
        Assert-AreEqual $resourceOwnerUsername $server.ResourceOwnerUsername
        Assert-AreEqual $supportState $server.SupportState
        Assert-AreEqual $tokenBodyParameters.Count $server.TokenBodyParameters.Count

        # update server
        $name = getAssetName
        $defaultScope = getAssetName
        $authorizationEndpoint = 'https://contoso.com/authv2'
        $tokenEndpoint = 'https://contoso.com/tokenv2'
        $clientRegistrationEndpoint = 'https://contoso.com/clients/regv2'
        $grantTypes = @('AuthorizationCode', 'Implicit', 'ClientCredentials')
        $authorizationMethods = @('Get')
        $bearerTokenSendingMethods = @('AuthorizationHeader')
        $clientId = getAssetName
        $description = getAssetName
        $clientAuthenticationMethods = @('Basic')
        $clientSecret = getAssetName
        $supportState = $false
        $tokenBodyParameters = @{'tokenname1'='tokenvalue1'}

        $server = Set-AzureRMApiManagementAuthorizationServer -Context $context -ServerId $serverId -Name $name -Description $description `
            -ClientRegistrationPageUrl $clientRegistrationEndpoint -AuthorizationEndpointUrl $authorizationEndpoint `
            -TokenEndpointUrl $tokenEndpoint -ClientId $clientId -ClientSecret $clientSecret -AuthorizationRequestMethods $authorizationMethods `
            -GrantTypes $grantTypes -ClientAuthenticationMethods $clientAuthenticationMethods -TokenBodyParameters $tokenBodyParameters `
            -SupportState $supportState -DefaultScope $defaultScope -AccessTokenSendingMethods $bearerTokenSendingMethods -PassThru

        Assert-AreEqual $serverId $server.ServerId
        Assert-AreEqual $name $server.Name
        Assert-AreEqual $defaultScope $server.DefaultScope
        Assert-AreEqual $authorizationEndpoint $server.AuthorizationEndpointUrl
        Assert-AreEqual $tokenEndpoint $server.TokenEndpointUrl
        Assert-AreEqual $clientRegistrationEndpoint $server.ClientRegistrationPageUrl
        Assert-AreEqual $grantTypes.Count $server.GrantTypes.Count
        Assert-AreEqual $grantTypes[0] $server.GrantTypes[0]
        Assert-AreEqual $grantTypes[1] $server.GrantTypes[1]
        Assert-AreEqual $grantTypes[2] $server.GrantTypes[2]
        Assert-AreEqual $authorizationMethods.Count $server.AuthorizationRequestMethods.Count
        Assert-AreEqual $authorizationMethods[0] $server.AuthorizationRequestMethods[0]
        Assert-AreEqual $bearerTokenSendingMethods.Count $server.AccessTokenSendingMethods.Count
        Assert-AreEqual $bearerTokenSendingMethods[0] $server.AccessTokenSendingMethods[0]
        Assert-AreEqual $clientId $server.ClientId
        Assert-AreEqual $description $server.Description
        Assert-AreEqual $clientAuthenticationMethods.Count $server.ClientAuthenticationMethods.Count
        Assert-AreEqual $clientAuthenticationMethods[0] $server.ClientAuthenticationMethods[0]
        Assert-AreEqual $clientSecret $server.ClientSecret
        #Assert-AreEqual $resourceOwnerPassword $server.ResourceOwnerPassword
        #Assert-AreEqual $resourceOwnerUsername $server.ResourceOwnerUsername
        Assert-AreEqual $supportState $server.SupportState
        Assert-AreEqual $tokenBodyParameters.Count $server.TokenBodyParameters.Count

        $server = Get-AzureRMApiManagementAuthorizationServer -Context $context -ServerId $serverId

        Assert-AreEqual $serverId $server.ServerId
        Assert-AreEqual $name $server.Name
        Assert-AreEqual $defaultScope $server.DefaultScope
        Assert-AreEqual $authorizationEndpoint $server.AuthorizationEndpointUrl
        Assert-AreEqual $tokenEndpoint $server.TokenEndpointUrl
        Assert-AreEqual $clientRegistrationEndpoint $server.ClientRegistrationPageUrl
        Assert-AreEqual $grantTypes.Count $server.GrantTypes.Count
        Assert-AreEqual $grantTypes[0] $server.GrantTypes[0]
        Assert-AreEqual $grantTypes[1] $server.GrantTypes[1]
        Assert-AreEqual $grantTypes[2] $server.GrantTypes[2]
        Assert-AreEqual $authorizationMethods.Count $server.AuthorizationRequestMethods.Count
        Assert-AreEqual $authorizationMethods[0] $server.AuthorizationRequestMethods[0]
        Assert-AreEqual $authorizationMethods[1] $server.AuthorizationRequestMethods[1]
        Assert-AreEqual $bearerTokenSendingMethods.Count $server.AccessTokenSendingMethods.Count
        Assert-AreEqual $bearerTokenSendingMethods[0] $server.AccessTokenSendingMethods[0]
        Assert-AreEqual $bearerTokenSendingMethods[1] $server.AccessTokenSendingMethods[1]
        Assert-AreEqual $clientId $server.ClientId
        Assert-AreEqual $description $server.Description
        Assert-AreEqual $clientAuthenticationMethods.Count $server.ClientAuthenticationMethods.Count
        Assert-AreEqual $clientAuthenticationMethods[0] $server.ClientAuthenticationMethods[0]
        Assert-AreEqual $clientSecret $server.ClientSecret
        #Assert-AreEqual $resourceOwnerPassword $server.ResourceOwnerPassword
        #Assert-AreEqual $resourceOwnerUsername $server.ResourceOwnerUsername
        Assert-AreEqual $supportState $server.SupportState
        Assert-AreEqual $tokenBodyParameters.Count $server.TokenBodyParameters.Count
    }
    finally
    {
        # remove created server
        $removed = Remove-AzureRMApiManagementAuthorizationServer -Context $context -ServerId $serverId -Force -PassThru
        Assert-True {$removed}

        $server = $null
        try
        {
            # check it was removed
            $server = Get-AzureRMApiManagementAuthorizationServer -Context $context -ServerId $serverId
        }
        catch
        {
        }

        Assert-Null $server
    }
}