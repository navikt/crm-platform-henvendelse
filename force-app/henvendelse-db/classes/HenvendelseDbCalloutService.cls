public with sharing class HenvendelseDbCalloutService extends ApiController {
    private final string CONFIG_NAME = 'HENVENDELSE_DB_API';
    private final string SERVICE_AUTH_HEADER = 'HenvendelseDB';

    public enum SERVICES {
        POST_HENVENDELSE_DB_API,
        PUT_HENVENDELSER_DB_API
    }

    public HttpResponse postHenvendelse(String body) {
        initRequest(CONFIG_NAME, SERVICES.POST_HENVENDELSE_DB_API.name());
        setSystemContext();
        addServiceAuthHeader(SERVICE_AUTH_HEADER);
        setBody(body);

        setHeaders(new Map<String, String>{
            'Content-Type' => 'application/json',
            'accept' => 'application/json'
        });

        doCallout();
        return getResponse();
    }

    public HttpResponse putHenvendelser(String body) {
        initRequest(CONFIG_NAME, SERVICES.PUT_HENVENDELSER_DB_API.name());
        setSystemContext();
        addServiceAuthHeader(SERVICE_AUTH_HEADER);
        setBody(body);

        setHeaders(new Map<String, String>{
            'Content-Type' => 'application/json',
            'accept' => 'application/json'
        });

        doCallout();
        return getResponse();
    }
}