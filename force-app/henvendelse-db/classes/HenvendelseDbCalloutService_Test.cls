@isTest
public class HenvendelseDbCalloutService_Test {
    private static HenvendelseDbCalloutService service = new HenvendelseDbCalloutService();

    @isTest
    static void testPostHenvendelse(){
        ApiMock.setTestMock(HenvendelseDbCalloutService.SERVICES.POST_HENVENDELSE_DB_API.name(), 200, 'OK');

        String body='{test}';
        Test.startTest();
        HttpResponse resp = service.postHenvendelse(body);
        Test.stopTest();

        Assert.areEqual(200, resp.getStatusCode(), 'Returned status code should be 200');
    }
}