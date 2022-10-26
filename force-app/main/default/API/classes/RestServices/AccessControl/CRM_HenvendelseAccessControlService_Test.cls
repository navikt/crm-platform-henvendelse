@isTest
private class CRM_HenvendelseAccessControlService_Test {
    
    @isTest
    private static void testCheckPersonAccess_whenPersonIsUgradert(){
        String body = '{"@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users(onPremisesSamAccountName)/$entity","onPremisesSamAccountName": "H157299"}';
        SingleRequestMock httpMock = new SingleRequestMock(200, 'Success', body, null);
        Test.setMock(HttpCalloutMock.class, httpMock);

        CRM_HenvendelseAccessControlService accessControlService=new CRM_HenvendelseAccessControlService('token');
        Boolean hasAccess=accessControlService.checkPersonAccess('UGRADERT', false);
        System.assertEquals(true,hasAccess,'User should always has access to UGRADERT');
    }

    @isTest
    private static void testCheckPersonAccess_whenPersonIsFortroligAndUserHasNotAccess(){
        String body = '{"@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users(onPremisesSamAccountName)/$entity","onPremisesSamAccountName": "H157299"}';
        SingleRequestMock httpMock = new SingleRequestMock(200, 'Success', body, null);
        Test.setMock(HttpCalloutMock.class, httpMock);

        CRM_HenvendelseAccessControlService accessControlService=new CRM_HenvendelseAccessControlService('token');
        Boolean hasAccess=accessControlService.checkPersonAccess('FORTROLIG', false);
        System.assertEquals(false,hasAccess,'User do not have access to FORTROLIG');
    }

    @isTest
    private static void testCheckPersonAccess_whenPersonIsFortroligAndUserHasAccess(){
        String body = '{"@odata.context": "https://graph.microsoft.com/v1.0/$metadata#directoryObjects(id)","value": [{"@odata.type": "#microsoft.graph.group","id": "3db683fb-ba0d-4d1a-aa92-153b101d9c88"}]}';
        SingleRequestMock httpMock = new SingleRequestMock(200, 'Success', body, null);
        Test.setMock(HttpCalloutMock.class, httpMock);

        CRM_HenvendelseAccessControlService accessControlService=new CRM_HenvendelseAccessControlService('token');
        Boolean hasAccess=accessControlService.checkPersonAccess('FORTROLIG', false);
        System.assertEquals(true,hasAccess,'User have access to FORTROLIG');
    }
    
    @isTest
    private static void testCheckPersonAccess_whenPersonIsStrengtFortroligAndUserHasNotAccess(){
        String body = '{"@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users(onPremisesSamAccountName)/$entity","onPremisesSamAccountName": "H157299"}';
        SingleRequestMock httpMock = new SingleRequestMock(200, 'Success', body, null);
        Test.setMock(HttpCalloutMock.class, httpMock);

        CRM_HenvendelseAccessControlService accessControlService=new CRM_HenvendelseAccessControlService('token');
        Boolean hasAccess=accessControlService.checkPersonAccess('STRENGT_FORTROLIG', false);
        System.assertEquals(false,hasAccess,'User do not have access to STRENGT_FORTROLIG');
    }

    @isTest
    private static void testCheckPersonAccess_whenPersonIsStrengtFortroligAndUserHasAccess(){
        String body = '{"@odata.context": "https://graph.microsoft.com/v1.0/$metadata#directoryObjects(id)","value": [{"@odata.type": "#microsoft.graph.group","id": "3db683fb-ba0d-4d1a-aa92-153b101d9c88"}]}';
        SingleRequestMock httpMock = new SingleRequestMock(200, 'Success', body, null);
        Test.setMock(HttpCalloutMock.class, httpMock);

        CRM_HenvendelseAccessControlService accessControlService=new CRM_HenvendelseAccessControlService('token');
        Boolean hasAccess=accessControlService.checkPersonAccess('STRENGT_FORTROLIG', false);
        System.assertEquals(true,hasAccess,'User have access to STRENGT_FORTROLIG');
    }

    @isTest
    private static void testCheckPersonAccess_whenPersonIsSkjermetAndUserHasNotAccess(){
        String body = '{"@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users(onPremisesSamAccountName)/$entity","onPremisesSamAccountName": "H157299"}';
        SingleRequestMock httpMock = new SingleRequestMock(200, 'Success', body, null);
        Test.setMock(HttpCalloutMock.class, httpMock);

        CRM_HenvendelseAccessControlService accessControlService=new CRM_HenvendelseAccessControlService('token');
        Boolean hasAccess=accessControlService.checkPersonAccess('UGRADERT', true);
        System.assertEquals(false,hasAccess,'User do not have access to SKJERMET');
    }

    @isTest
    private static void testCheckPersonAccess_whenPersonIsSkjermetAndUserHasAccess(){
        String body = '{"@odata.context": "https://graph.microsoft.com/v1.0/$metadata#directoryObjects(id)","value": [{"@odata.type": "#microsoft.graph.group","id": "3db683fb-ba0d-4d1a-aa92-153b101d9c88"}]}';
        SingleRequestMock httpMock = new SingleRequestMock(200, 'Success', body, null);
        Test.setMock(HttpCalloutMock.class, httpMock);

        CRM_HenvendelseAccessControlService accessControlService=new CRM_HenvendelseAccessControlService('token');
        Boolean hasAccess=accessControlService.checkPersonAccess('UGRADERT', true);
        System.assertEquals(true,hasAccess,'User have access to UGRADERT');
    }
}
