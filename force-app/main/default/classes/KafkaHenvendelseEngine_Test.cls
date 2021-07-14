@isTest
public class KafkaHenvendelseEngine_Test {
    private static final String SPORSMAL_UTGAAENDE = '{\"henvendelseId\":123,\"behandlingsId\":\"1001ABBA\",\"behandlingskjedeId\":\"1001ABBA\",\"applikasjonsId\":null,\"fnr\":\"0120000123\",\"aktorId\":\"1000010000123\",\"tema\":\"BID\",\"behandlingstema\":\"KNA\",\"ferdigstiltUtenSvar\":true,\"henvendelseType\":\"SPORSMAL_MODIA_UTGAAENDE\",\"eksternAktor\":\"Z999999\",\"tilknyttetEnhet\":\"1234\",\"opprettetDato\":\"2021-07-12T14:35:42.473706+02:00\",\"avsluttetDato\":\"2021-07-12T14:35:42.473708+02:00\",\"utgaarDato\":\"2021-10-21T14:35:42.473789+02:00\",\"lestDato\":\"2021-07-13T12:38:02.887825+02:00\",\"kontorsperreEnhet\":\"1234\",\"brukersEnhet\":\"123456\",\"markertSomFeilsendtAv\":\"Z999999\",\"oppgaveIdGsak\":\"12345678\",\"henvendelseIdGsak\":\"ABBA123456\",\"erTilknyttetAnsatt\":true,\"gjeldendeTemagruppe\":\"OKSOS\",\"journalfortInformasjon\":{\"journalpostId\":\"123456789\",\"journalfortTema\":\"DAG\",\"journalfortDato\":\"2021-07-13T12:46:34.554845+02:00\",\"journalfortSaksId\":\"123456asd\",\"journalforerNavIdent\":\"Z999999\",\"journalforendeEnhet\":\"1234\"},\"markeringer\":{\"kontorsperre\":{\"dato\":\"2021-07-13T12:38:02.887825+02:00\",\"aktor\":\"Z999999\",\"enhet\":\"1234\"},\"feilsendt\":{\"dato\":\"2021-07-13T12:38:02.887825+02:00\",\"aktor\":\"Z999999\"},\"ferdigstiltUtenSvar\":{\"dato\":\"2021-07-13T12:38:02.887825+02:00\",\"aktor\":\"Z999999\"}},\"korrelasjonsId\":\"202cb962-ac59-375b-964b-07152d234b70\",\"metadataListe\":{\"metadata\":[{\"temagruppe\":\"UFRT\",\"fritekst\":\"Bekrefter at siste utbetaling gjelder november måned og at utbetaling for desember vil utbetales i løpet av uke 50.\\n    Dette er min id: 123 (3f)\\n        \",\"sporsmalsId\":null,\"kanal\":\"TELEFON\",\"navident\":\"Z999999\"}]},\"KAFKA_MESSAGE_VERSION\":\"1.0\"}';

    @TestSetup
    static void makeData() {
        Person__c dummyPerson = (Person__c) CRM_HENV_TestDataFactory.createRecord(
            new Person__c(Name = '0120000123', INT_ActorId__c = '1000010000123')
        );

        User accountOwner = [
            SELECT Id
            FROM User
            WHERE UserRoleId != NULL AND isActive = TRUE AND IsPortalEnabled = FALSE
            LIMIT 1
        ];

        Account personAcc = [
            SELECT Id, FirstName, LastName, PersonContactId
            FROM Account
            WHERE CRM_Person__c = :dummyPerson.Id
            LIMIT 1
        ];
        personAcc.OwnerId = accountOwner.Id;
        update personAcc;

        Profile portalProfile = [SELECT Id, Name FROM Profile WHERE UserType = 'CspLitePortal' LIMIT 1];
        User portalUser = (User) CRM_HENV_TestDataFactory.createRecord(
            new User(
                FirstName = personAcc.FirstName,
                LastName = personAcc.LastName,
                ContactId = personAcc.PersonContactId,
                ProfileId = portalProfile.Id,
                Username = personAcc.FirstName + '.' + personAcc.LastName + '@testing.com'
            )
        );

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        messages.add(
            new KafkaMessage__c(
                CRM_Key__c = '1001ABBA',
                CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf(SPORSMAL_UTGAAENDE)),
                CRM_Topic__c = 'Henvendelse-Migration'
            )
        );

        insert messages;
    }

    @isTest
    static void testHenvendelseHandling() {
        Test.startTest();
        Database.executeBatch(new KafkaHenvendelseEngine(), 200);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Thread__c]);
    }
}
