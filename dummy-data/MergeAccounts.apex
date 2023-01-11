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
    if(accMap.get(ident).size() > 1) {
        Account master;
        List<Account> duplicates = new List<Account>();
        for(Account acc : accMap.get(ident)) {
            if(master == null && acc.CRM_Person__r.CRM_Account__c != null) {
                master = new Account(Id = acc.Id);
            } else {
                duplicates.add(new Account(Id = acc.Id));
            }
        }

        if(master == null) {
            master = duplicates.remove(0);
        }
        Database.merge(master, duplicates);
    }
}