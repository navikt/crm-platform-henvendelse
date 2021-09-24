global class CRM_ReferenceUtil {
    global static String generateReference(SObject sObj) {
        Blob randomizer = Crypto.GenerateAESKey(128);
        String hexRef = EncodingUtil.ConvertTohex(randomizer);
        String objPrefix = sObj.getSObjectType().getDescribe().getKeyPrefix();

        return objPrefix + hexRef.substring(0, 15);
    }
}
