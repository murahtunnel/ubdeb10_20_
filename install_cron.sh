#!/bin/bash

clear


    cat >/etc/cron.d/xp_all <<-END
		SHELL=/bin/sh
		PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
		2 0 * * * root /usr/bin/xp
	END
    cat >/etc/cron.d/logclean <<-END
		SHELL=/bin/sh
		PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
		*/59 * * * * root /usr/bin/logclean
	END
	    cat >/etc/cron.d/daily_reboot <<-END
		SHELL=/bin/sh
		PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
		0 5 * * * /sbin/reboot
	END
    cat >/etc/cron.d/autobackup <<-END
		SHELL=/bin/sh
		PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
		2 0 * * * root /usr/local/sbin/autobackup
	END
    cat >/etc/cron.d/kill_exp <<-END	
	    SHELL=/bin/bash
        PATH=/sbin:/bin:/usr/sbin:/usr/bin
        */1 * * * * root /usr/local/sbin/kill_expired exp
        */1 * * * * root /usr/local/sbin/kill_expired vm
        */1 * * * * root /usr/local/sbin/kill_expired vl
        */1 * * * * root /usr/local/sbin/kill_expired tr
        */1 * * * * root /usr/local/sbin/kill_expired ssh                                
	END