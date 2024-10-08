/**
 * This class is part of the sfdx-batch-orchestrator package, released under the MIT license.
 *
 * @description       : Test Class to verify the Finalizer Interface in BatchJobBase works.
 * @author            : dschibster
 * @group             : Scheduler
 * @last modified on  : 2021-08-27
 * @last modified by  : dschibster
 **/

@isTest
public with sharing class BatchJobBaseTest {
    @isTest
    static void testFinalizerInterfaceFired() {
        Test.startTest();
        BatchJobBase emptyQueueable = (BatchJobBase) new testQueueable();
        emptyQueueable.jobType = 'Queueable';
        emptyQueueable.className = 'testQueueable';
        emptyQueueable.enqueue(null);
        Test.stopTest();

        System.assert(![SELECT Id FROM Batch_Job_Log__c].isEmpty(), 'Finalizer has not created a Batch log.');
    }

    @isTest
    static void shouldCreateEnhancedLogs() {
        Test.startTest();
        BatchJobBase enhancedLoggingBatchJob = (BatchJobBase) new TestBatchJob2();
        enhancedLoggingBatchJob.enhancedLoggingEnabled = true;
        enhancedLoggingBatchJob.jobType = 'Batchable';
        enhancedLoggingBatchJob.className = 'TestBatchJob1';

        Id asyncJobId = enhancedLoggingBatchJob.enqueue(10);
        enhancedLoggingBatchJob.startLogging(asyncJobId);
        enhancedLoggingbatchJob.logInformation(new List<Account>{ new Account(Name = 'Test Batch Job') }, asyncJobId, 'test');
        enhancedLoggingbatchJob.logInformation(asyncJobId, 'test');
        enhancedLoggingbatchJob.logEndOfBatch(new List<Account>{ new Account(Name = 'Test Batch Job') }, asyncJobId, true, 'test');
        enhancedLoggingbatchJob.logEndOfBatch(new List<Account>{ new Account(Name = 'Test Batch Job') }, asyncJobId, false, 'test');
        enhancedLoggingbatchJob.logStartInformation(asyncJobId, 'test');
        enhancedLoggingbatchJob.logFinishInformation(asyncJobId, 'test');

        Test.stopTest();

        System.assertEquals(
            8,
            [SELECT COUNT() FROM Batch_Job_Log__c WHERE RecordTypeId = :RecordTypeCache.LOG_RECORD_TYPE_CHILD],
            'Needed to create 6 Child Logs (5 manual, one automatic from finish method), that did not happen'
        );
    }

    @isTest
    static void shouldCreateLegacyLogs() {
        Test.startTest();
        BatchJobBase enhancedLoggingBatchJob = (BatchJobBase) new TestBatchJob1();
        enhancedLoggingBatchJob.enhancedLoggingEnabled = false;
        enhancedLoggingBatchJob.jobType = 'Batchable';
        enhancedLoggingBatchJob.className = 'TestBatchJob1';

        Id asyncJobId = enhancedLoggingBatchJob.enqueue(10);
        Test.stopTest();

        System.assertEquals(
            1,
            [SELECT COUNT() FROM Batch_Job_Log__c WHERE RecordTypeId = :RecordTypeCache.LOG_RECORD_TYPE_LEGACY],
            'No Legacy Log was created'
        );
    }

    @isTest
    static void shouldCreateErrorLogs() {
        BatchJobSchedulerTestDataFactory.createBatchSchedulerContext();

        try {
            Test.startTest();
            BatchJobBase enhancedLoggingBatchJob = (BatchJobBase) new TestBatchJobForceError();
            enhancedLoggingBatchJob.enhancedLoggingEnabled = true;
            enhancedLoggingBatchJob.jobType = 'Batchable';
            enhancedLoggingBatchJob.className = 'TestBatchJobForceError';
            Id asyncJobId = enhancedLoggingBatchJob.enqueue(3);
            Test.stopTest();
        } catch (Exception e) {
            //silent failure for Platform Event publishing
        }
        Test.getEventBus().deliver(); //this delivers the Error Event
        Test.getEventBus().deliver(); //this delivers the new Status Event

        System.assertEquals(1, [SELECT COUNT() FROM Batch_Job_Log__c WHERE Result__c = 'Error'], 'No Error Log was created');
    }
}
