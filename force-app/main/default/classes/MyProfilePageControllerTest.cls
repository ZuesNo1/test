@IsTest
public with sharing class MyProfilePageControllerTest {

    @IsTest
    static void testInitialization() {
        // Test initialization for non-guest user
        User testUser = [SELECT id, usertype FROM User WHERE UserType != 'Guest' LIMIT 1];
        System.runAs(testUser) {
            MyProfilePageController controller = new MyProfilePageController();
            System.assertEquals(testUser.Id, controller.getUser().Id, 'User should be initialized correctly');
        }

        // Test initialization for guest user
        try {
            User guestUser = [SELECT id, usertype FROM User WHERE UserType = 'Guest' LIMIT 1];
            System.runAs(guestUser) {
                MyProfilePageController controller = new MyProfilePageController();
            }
            System.assert(false, 'NoAccessException should have been thrown for guest user');
        } catch (Exception e) {
            System.assert(e instanceof NoAccessException, 'Exception should be NoAccessException');
        }
    }

    @IsTest
    static void testGetIsEdit() {
        User testUser = [SELECT id FROM User LIMIT 1];
        System.runAs(testUser) {
            MyProfilePageController controller = new MyProfilePageController();
            System.assertEquals(false, controller.getIsEdit(), 'isEdit should be false initially');
        }
    }

    @IsTest
    static void testEdit() {
        User testUser = [SELECT id FROM User LIMIT 1];
        System.runAs(testUser) {
            MyProfilePageController controller = new MyProfilePageController();
            controller.edit();
            System.assertEquals(true, controller.getIsEdit(), 'isEdit should be true after calling edit');
        }
    }


    @IsTest
    static void testChangePassword() {
        User testUser = [SELECT id FROM User LIMIT 1];
        System.runAs(testUser) {
            MyProfilePageController controller = new MyProfilePageController();
            PageReference pageRef = controller.changePassword();
            System.assertEquals(Page.ChangePassword.getUrl(), pageRef.getUrl(), 'changePassword should return the correct PageReference');
        }
    }

    @IsTest
    static void testCancel() {
        User testUser = [SELECT id FROM User LIMIT 1];
        System.runAs(testUser) {
            MyProfilePageController controller = new MyProfilePageController();
            controller.edit();
            controller.cancel();
            System.assertEquals(false, controller.getIsEdit(), 'isEdit should be false after calling cancel');
            User reloadedUser = [SELECT id FROM User WHERE Id = :testUser.Id];
            System.assertEquals(testUser.Id, reloadedUser.Id, 'User should be reloaded');
        }
    }
    @IsTest
    static void testSave() {
        User testUser = [SELECT id FROM User LIMIT 1];
        System.runAs(testUser) {
            MyProfilePageController controller = new MyProfilePageController();
            controller.edit();
            controller.getUser().FirstName = 'Test';
            controller.save();
            User reloadedUser = [SELECT id, firstname FROM User WHERE Id = :testUser.Id];
            System.assertEquals('Automated', reloadedUser.FirstName, 'User should be updated');
        }
    }
}