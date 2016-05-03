START TRANSACTION;

    INSERT INTO category (slug, name, source_ref)
    VALUES
        ('top-apps', 'Top Apps', 'At0EFWTR6D'),
        ('brilliant-bots', 'Brilliant Bots', 'At0EFT6813'),
        ('analytics', 'Analytics', 'At0MQP5BEF'),
        ('communication', 'Communication', 'At0EFT6869'),

        ('customer-support', 'Customer Support', 'At0EFRCDQC'),
        ('design', 'Design', 'At0EFX4CCE'),
        ('developer-tools', 'Developer Tools', 'At0EFRCDNY'),
        ('file-management', 'File Management', 'At0EFRCDPW'),
        ('health-medical', 'Health Medical', 'At0MRS55PA'),
        ('hr', 'Human Resources', 'At0EFT6893'),
        ('marketing', 'Marketing', 'At0EFRCDQU'),
        ('new-noteworthy', 'New and Noteworthy', 'At0EFT67V3'),
        ('office-management', 'Office Management', 'At0EFWTRAM'),
        ('payments-accounting', 'Payments Accounting', 'At0EFX9EF9'),
        ('productivity', 'Productivity', 'At0EFXUU6N'),
        ('project-management', 'Project Management', 'At0EFY3MJ4'),
        ('security-compliance', 'Security Compliance', 'At0EFWTRA5'),
        ('social-fun', 'Social & Fun', 'At0EFXUU0J'),
        ('travel', 'Travel', 'At0QUNV823');

COMMIT TRANSACTION;
