public with sharing class CRM_HenvendelseAccessControlService {
    public String navId;
    private MicrosoftGraphService microsoftGraphService;
    private String AD_GROUP_FORTROLIG='0000-GA-Fortrolig_Adresse';
    private String AD_GROUP_STRENGT_FORTROLIG='0000-GA-Strengt_Fortrolig_Adresse';
    private String AD_GROUP_SKJERMET='0000-GA-GOSYS_UTVIDET';
    private String AD_GROUP_SKJERMET2='0000-GA-Pensjon_UTVIDET';
    
    public CRM_HenvendelseAccessControlService(String microsofGraphToken) {
        
        microsoftGraphService=new MicrosoftGraphService(microsofGraphToken);
        //get nav-id
        MicrosoftGraphService.MicrosoftGraphResponse res= microsoftGraphService.getNavId();
        this.navId=res.navId;
    }

    public Boolean checkPersonAccess(String confidential, Boolean isNavEmployee){
        return checkConfidentialAccess(confidential) && checkSkjermetAccess(isNavEmployee);
    }

    private Boolean checkConfidentialAccess(String confidential){
        switch on confidential {
            when 'UGRADERT' {
                return true;
            }
            when 'FORTROLIG' {
               return microsoftGraphService.getMemberOfGroup(AD_GROUP_FORTROLIG).isMember;
            }
            when 'STRENGT_FORTROLIG' {
                return microsoftGraphService.getMemberOfGroup(AD_GROUP_STRENGT_FORTROLIG).isMember; 
            }
        }
        return false;
    }

    private Boolean checkSkjermetAccess(Boolean isNavEmployee){
        if(!isNavEmployee) {
            return true;
        }
        Boolean hasAccess=microsoftGraphService.getMemberOfGroup(AD_GROUP_SKJERMET).isMember; 
        //must check to ad group for skjermet access
        if(!hasAccess){
            hasAccess=microsoftGraphService.getMemberOfGroup(AD_GROUP_SKJERMET2).isMember;
        }
        return hasAccess;
    }
}
