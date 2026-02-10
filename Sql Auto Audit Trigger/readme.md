Veritabanındaki istenen tablolarda insert, update, delete işlemlerini kim ne zaman yaptı neyi hangi bilgisayardan değiştirdi. takip edebilmek için triggerları otomatik oluşturan prosedür. 


sp_AutoAudit_Olustur adlı prosedür, tabloadı ve alan dğeişkenlerini alır bunlara uygun triggeri otomatik olarak yazar, trigger ise işlemleri takip edip, AuditLog tablosuna insert eder. 