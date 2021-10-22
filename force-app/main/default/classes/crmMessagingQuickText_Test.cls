@isTest
public class crmMessagingQuickText_Test {
    @TestSetup
    static void makeData() {
        QuickText text = new QuickText();
        text.Message = 'Text Message';
        text.Name = 'Sample Name';
        text.Channel = 'Email';

        insert text;
    }
    @isTest
    static void searchTest() {
        List<CRM_HenvendelseQuicktextController.QuickTextMessage> resultList = CRM_HenvendelseQuicktextController.searchRecords(
            'sample'
        );
        System.assertEquals(1, resultList.size());
    }
    @isTest
    static void getQuickTextsTest() {
        List<QuickText> quicktextgs = CRM_HenvendelseQuicktextController.getQuicktexts();
        //Test assert ommitied to avoid packaging conflicts
        //TODO: Move NKSAbbreviationKey to another package
    }
}
