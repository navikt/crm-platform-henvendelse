global virtual class ApexRestService {
    private static final Map<Integer, String> DEFAULT_RESPONSE_MAP = new Map<Integer, String>{
        200 => 'OK',
        201 => 'CREATED',
        202 => 'ACCEPTED',
        400 => 'BAD_REQUEST',
        401 => 'UNAUTHORIZED',
        403 => 'FORBIDDEN',
        404 => 'NOT_FOUND',
        500 => 'INTERNAL_SERVER_ERROR'
    };

    /**
     * @description: sets the response code for the RestContext
     * @author Stian Ruud Schikora | 06-22-2021
     * @param responseCode
     **/
    global static void setResponse(Integer responseCode) {
        // Instantiate the RestResponse
        RestResponse response = RestContext.response;
        response.statusCode = responseCode;
        if (DEFAULT_RESPONSE_MAP.containsKey(responseCode))
            response.responseBody = Blob.valueOf(DEFAULT_RESPONSE_MAP.get(responseCode));
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
        RestRequest request = RestContext.request;
        return request.params.containsKey(paramName) ? request.params.get(paramName) : null;
    }

    /**
     * @description: Returns the last path parameter in the request URI. If the URI ends with '/' this is removed
     * @author Stian Ruud Schikora | 06-22-2021
     * @return String
     **/
    global static String getLastPathParameter() {
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
        RestRequest request = RestContext.request;
        return request.requestURI.substringBetween(firstMatch + '/', '/' + secondMatch);
    }

    /**
     * @description: Generic validation for all rest services extending this super class
     * @author Stian Ruud Schikora | 07-05-2021
     * @return Boolean
     **/
    global static Boolean validate() {
        //All endpoints must have a unique correlation ID used for troubleshooting in the callout chain
        RestRequest request = RestContext.request;
        Boolean valid = request.headers.containsKey('X-Correlation-ID');
        if (!valid) {
            setResponse(400, 'Missing required parameter: X-Correlation-ID');
        }
        return valid;
    }
}
