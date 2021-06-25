global virtual class ApexRestService {
    /**
     * @description: sets the response code for the RestContext
     * @author Stian Ruud Schikora | 06-22-2021
     * @param responseCode
     **/
    global static void setResponse(Integer responseCode) {
        // Instantiate the RestResponse
        RestResponse response = RestContext.response;
        response.statusCode = responseCode;
    }

    /**
     * @description: Sets the response code and payload for the RestContext.
     * @author Stian Ruud Schikora | 06-22-2021
     * @param responseCode
     * @param payload
     **/
    global static void setResponse(Integer responseCode, String payload) {
        // Instantiate the RestResponse
        RestResponse response = RestContext.response;
        response.statusCode = responseCode;
        if (String.isNotBlank(payload))
            response.responseBody = Blob.valueOf(payload);
    }

    /**
     * @description: Returns the query parameter from the request with the specified parameter name, null if not existing.
     * @author Stian Ruud Schikora | 06-22-2021
     * @param paramName
     * @return String
     **/
    global static String getRequestParam(String paramName) {
        // Instantiate the RestResponse
        RestRequest request = RestContext.request;
        return request.params.containsKey(paramName) ? request.params.get(paramName) : null;
    }

    /**
     * @description: Returns the last path parameter in the request URI. If the URI ends with '/' this is removed
     * @author Stian Ruud Schikora | 06-22-2021
     * @return String
     **/
    global static String getLastPathParameter() {
        // Instantiate the RestResponse
        RestRequest request = RestContext.request;
        return request.requestURI.substringAfterLast('/').remove('/');
    }

    /**
     * @description: Returns the part of the URI path between two strings. i.e. for a path /account/{accountId}/search/{contactName}
     * a call with firstMatch = account and secondMatch = search should return the accountId path parameter
     * @author Stian Ruud Schikora | 06-22-2021
     * @param firstMatch
     * @param secondMatch
     * @return String
     **/
    global static String getPathStringBetween(String firstMatch, String secondMatch) {
        // Instantiate the RestResponse
        RestRequest request = RestContext.request;
        return request.requestURI.substringBetween(firstMatch + '/', '/' + secondMatch);
    }
}
