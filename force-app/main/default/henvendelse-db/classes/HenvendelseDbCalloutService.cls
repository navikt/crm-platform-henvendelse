public with sharing class HenvendelseDbCalloutService extends ApiController {
    private final string CONFIG_NAME = 'HENVENDELSE_DB_API';
    private final string SERVICE_AUTH_HEADER = 'HenvendelseDB';

    public HenvendelseDbCalloutService(){
        LoggerUtility logger = new LoggerUtility('HenvendelseDB');
        setLogCategory('HenvendelseDB').
        setLogger(logger).
        setLogCalloutRequest().
        publishLogAfterCallout().
        setLogDomain(CRM_ApplicationDomain.Domain.NKS);
    }

    public enum SERVICES {
        POST_HENVENDELSE_DB_API
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
}