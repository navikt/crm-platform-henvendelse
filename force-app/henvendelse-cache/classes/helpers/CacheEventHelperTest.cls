@IsTest
public class CacheEventHelperTest {
    
    @IsTest
    static void shouldStoreOneInfoLogRecordWhenOneCacheHenvendelseItem(){
        CacheHenvendelse henvendelse= new CacheHenvendelse('12345', '43434');

        Test.startTest();
        CacheEventHelper.publish(new List<CacheHenvendelse>{henvendelse}, 'ConversationNote');
        Test.stopTest();

        Assert.areEqual(
            1,
            [SELECT COUNT() FROM Application_Log__c WHERE Log_Level__c='INFO']
        );
    }
}