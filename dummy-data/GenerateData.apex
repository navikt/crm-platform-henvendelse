//Fix merge person and account
Map<String,List<Account>> accMap = new Map<String,List<Account>>();
for(Account acc : [SELECT Id, INT_PersonIdent__c, CRM_Person__r.CRM_Account__c FROM Account]) {
    if(String.isBlank(acc.INT_PersonIdent__c)) {
        continue;
    }

    if(accMap.containsKey(acc.INT_PersonIdent__c) == false) {
        accMap.put(acc.INT_PersonIdent__c, new List<Account>());
    }

    accMap.get(acc.INT_PersonIdent__c).add(acc);
}

for(String ident : accMap.keySet()) {
    system.debug(accMap.get(ident));
    if(accMap.get(ident).size() > 1) {
        Account master;
        List<Account> duplicates = new List<Account>();
        for(Account acc : accMap.get(ident)) {
            if(acc.CRM_Person__r.CRM_Account__c == null) {
                duplicates.add(new Account(Id = acc.Id));
            } else {
                master = new Account(Id = acc.Id);
            }
        }

        Database.merge(master, duplicates);
    }
}

//Set user role
if(String.isBlank(UserInfo.getUserRoleId())) {
    update new User(Id = UserInfo.getUserId(), UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'NKS'][0].Id);
}

//Dummy data script for creating community user and associated dummy data
Account communityAccount = [SELECT Id, FirstName, LastName, PersonContactId FROM Account WHERE CRM_Person__r.Name = '12345678901' LIMIT 1];

Profile portalProfile = [SELECT Id, Name FROM Profile WHERE UserType = 'PowerCustomerSuccess' and Name = 'Customer Community Plus User' LIMIT 1];


User portalUser = new User();
portalUser.FirstName = communityAccount.FirstName;
portalUser.LastName = communityAccount.LastName;
portalUser.ContactId = communityAccount.PersonContactId;
portalUser.Alias = 'hpott';
portalUser.Username = 'harry.potter@test.nav.henvendelse';
portalUser.Email = 'harry.potter@test.nav.henvendelse';
portalUser.ProfileId = portalProfile.Id;
portalUser.EmailEncodingKey = 'UTF-8';
portalUser.CommunityNickname = 'testUser1';
portalUser.TimeZoneSidKey = 'Europe/Paris';
portalUser.LocaleSidKey = 'no_NO';
portalUser.LanguageLocaleKey = 'no';
insert portalUser;


//Create a dummy thread
Thread__c thread = new Thread__c();
thread.CRM_From__c = portalUser.Id;
thread.CRM_isActive__c = true;
insert thread;

Message__c message = new Message__c(CRM_Thread__c = thread.Id,
                    CRM_Message_Text__c = 'Dette er en testmelding :)',
                    CRM_Read_Datetime__c = Datetime.now(),
                    CRM_Sent_Date__c = Datetime.now().addDays(-1));

insert message;

Journal_Entry__c jEntry = new Journal_Entry__c(
          CRM_Thread__c = thread.Id,
          Journal_Entry_Status__c = 'Completed',
          CRM_Journal_Date__c = Datetime.now(),
          CRM_Created_By_Ident__c = 'Z999999'  
);
insert jEntry;
