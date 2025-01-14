public with sharing class ModiaIntegrationUser {
    public Id UserId {
        get {
            return getUserId();
        }
    }

    private Id getUserId() {
        List<User> users = [
            SELECT Id
            FROM User
            WHERE Username LIKE 'modia.integrasjon@nav.no%'
        ];
        if (users.size() > 0) {
            return users[0].Id;
        }
        return null;
    }
}
