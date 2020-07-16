@isTest
public with sharing class WarehouseSyncScheduleTest {

    @isTest
    public static void warehouseSyncTest() {

        String CRON_EXP = '0 0 0 15 3 ? 2022';

        test.startTest();

        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

        String jobId = System.schedule('WarehouseSyncScheduleTest', CRON_EXP, new WarehouseSyncSchedule());
        System.debug(jobId);

        test.stopTest();
    }

}
