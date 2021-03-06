#include <linux/module.h>
#include <linux/version.h>
#include <linux/time.h>
#include <linux/ktime.h>
#include <linux/hrtimer.h>

#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/kdev_t.h>
#include <linux/cdev.h>
#include <linux/types.h>
#include <linux/sched.h>
#include <linux/delay.h>
#include <linux/interrupt.h>
#include <linux/irq.h>
#include <linux/errno.h>
#include <linux/ioport.h>
#include <linux/crc32.h>
#include <linux/platform_device.h>
#include <linux/spinlock.h>
#include <linux/ethtool.h>
#include <linux/mii.h>
#include <linux/workqueue.h>
#include <linux/fcntl.h>
#include <linux/ioctl.h>
#include <linux/netdevice.h>
#include <linux/etherdevice.h>
#include <linux/skbuff.h>
#include <linux/syscalls.h>
#include <linux/sys.h>
#include <linux/device.h>
#include <linux/timer.h>
#include <linux/param.h>
#include <linux/jiffies.h>
#include <linux/gpio.h>
#include <linux/io.h>
#include <linux/poll.h>

#include <asm/io.h>

#include "ioctl_chsthr.h"

#define KSDT_DRV_VERSION 	"2017-05-04"
#define KSDT_DEVNAME 	 	"thrksd"
#define KSDT_CHDEVNAME   	"chthrksd"

#define COUNT_DEVICES 1

#define DELAY 350 // 350 mc

static  int period = DELAY;
module_param(period,int,0);

MODULE_LICENSE("GPL");
MODULE_VERSION(KSDT_DRV_VERSION);
MODULE_ALIAS("chdriver:ksdthr");

static int SUCCESS;
static int FAIL = -1;
static int Major = 701;
static int Minor = 0;
static int Device_Status = 0;

static dev_t dev_ksdt;

//для внутренного представления символьных устройств:
//static struct cdev c_dev; 
struct cksdt_dev
{
        struct mutex mutex;
        struct cdev cdev;
};

static ktime_t tout;
static struct kt_data 
{
	struct hrtimer timer;//таймер высокого разрешения
   	ktime_t  period;
   	//int      numb;
}*data;

struct cksdt_dev c_dev;
struct cksdt_dev *ksdt_cdev; //&c_dev

static DECLARE_WAIT_QUEUE_HEAD(wqksdt);

struct timer_list ksd_timer;
static int flagksdt;

static void wakeUpUserMode(unsigned long par)
{
	flagksdt = 1;
	wake_up_interruptible(&wqksdt);// пробудить поток чтения
}

static enum hrtimer_restart ksd_timer_function ( struct hrtimer *var )
{
	ktime_t now = var->base->get_time();  // текущее время в типе ktime_t
   	//printk( KERN_INFO "timer run #%d at jiffies=%ld\n", data->numb, jiffies );
   	hrtimer_forward( var, now, tout );
	
	wakeUpUserMode(0);

   	//return data->numb-- > 0 ? HRTIMER_RESTART : HRTIMER_NORESTART;
	return HRTIMER_RESTART;
}

static void startTimer(int period)
{
	enum hrtimer_mode mode;
	unsigned long usec_period; 

   	mode = HRTIMER_MODE_REL;
	usec_period = (unsigned long)period * 1000000;
	tout = ktime_set( 0, usec_period );  /*expample: ktime_set( 1, 0 ) where 1 sec. + 0 nsec. */
   	data = kmalloc( sizeof(*data), GFP_KERNEL );
   	data->period = tout;

   	// используем системные часы CLOCK_REALTIME
   	hrtimer_init( &data->timer, CLOCK_REALTIME, mode );
   	data->timer.function = ksd_timer_function;
   	//data->numb = 3;

   	printk( KERN_INFO "KSDTHR: timer start at jiffies=%ld\n", jiffies );
   	hrtimer_start( &data->timer, data->period, mode );

	printk(KERN_INFO "KSDTHR: start timer %d mc",period);
}

static void stopTimer(void)
{
	/*del_timer_sync(&ksd_timer);*/
	printk(KERN_INFO "KSDTHR: stop timer mc");

	hrtimer_cancel( &data->timer );
   	kfree( data );
}

static long ksdt_ioctl(struct file *pfile,unsigned int cmd,unsigned long arg)
{
	int err;
	int retval;

	err = 0; retval = 0; 
	/* проверить тип и номер битовых полей и не декодировать
	* неверные команды: вернуть ENOTTY (неверный ioctl) перед access_ok( )
	*/


	if (_IOC_TYPE(cmd) != KSDT_IOC_MAGIC) return -ENOTTY;
	if (_IOC_NR(cmd) > KSDT_IOC_MAXNR) return -ENOTTY;

	/*
	 * направление является битовой маской и VERIFY_WRITE отлавливает передачи R/W
	 * `направление' является ориентированным на пользователя, в то время как
	 * access_ok является ориентированным на ядро, так что концепции "чтение" и
	 * "запись" являются обратными
	 */

	if (_IOC_DIR(cmd) & _IOC_READ)
		err = !access_ok(VERIFY_WRITE, (void __user *)arg, _IOC_SIZE(cmd));
	else if (_IOC_DIR(cmd) & _IOC_WRITE)
		err = !access_ok(VERIFY_READ, (void __user *)arg, _IOC_SIZE(cmd));


	if (err) return -EFAULT;

	switch(cmd)
	{
        	case KSDT_IOCRESET:
		{
			flagksdt = 1;
			wake_up_interruptible(&wqksdt);

			retval = 0;
		}
		break;
		case KSDT_IOCG_PERIOD:
		{
			//для записи простой переменной из пространства ядра в пространство пользователя
			retval = __put_user(period, (int __user *)arg);
                	if(retval!=0) { printk(KERN_ERR "KSDTHR: KSDT_IOCG_PERIOD error get period witch IOCTL"); }

		}
		break;
		case KSDT_IOCS_PERIOD:
		{
			//для считывания простой переменной из пространства пользователя. 
			retval = __get_user(period, (int __user *)arg);
			if(retval!=0) { printk(KERN_ERR "KSDTHR: KSDT_IOCS_PERIOD error set period witch IOCTL"); }
			else { 
					if(period!=0) 
					{
						printk(KERN_INFO "KSDTHR: KSDT_IOCS_PERIOD set period %d",period);
						stopTimer();
						udelay(5);
						startTimer(period);
					} else { printk(KERN_INFO "KSDTHR: KSDT_IOCS_PERIOD don't set period %d",period); }
			     }
		}
		break;
		default:  /* redundant, as cmd was checked against MAXNR */
		return -ENOTTY;
	}

	return retval;
}

static int ksdt_open(struct inode *inode, struct file *pfile)
{

	if(Device_Status>=COUNT_DEVICES) return -EBUSY;

	Device_Status++;

    	try_module_get(THIS_MODULE);//увеличить счётчик ссылок для модуля (возвращается признак успешности операции);

	startTimer(period);

    	printk(KERN_INFO "KSDTHR: ksdt_open, count %d\n",Device_Status);

    	return SUCCESS;	
}

static int ksdt_release(struct inode *inode, struct file *pfile)
{//close

	if(Device_Status>0)
	{
		Device_Status--;

		module_put(THIS_MODULE);//уменьшить счётчик ссылок для модуля;

		printk(KERN_INFO "KSDTHR: ksdt_release, count %d\n",Device_Status+1);
	}

	stopTimer();

	return SUCCESS;
}


static ssize_t ksdt_read (struct file *pfile, char __user *buffer, size_t length, loff_t *offset)
{//ssize_t - целое,

	if(wait_event_interruptible(wqksdt, flagksdt != 0)>0)
    	{
        	printk(KERN_ERR "KSDTHR: read error ERESTARTSYS");
        	return -ERESTARTSYS;
    	}
	flagksdt = 0;

	return 0;
}

static unsigned int ksdt_poll(struct file *pfile, poll_table *wait)
{
        unsigned int mask;
        mask = 0;

//-----------------------------------------------------------------
//	printk(KERN_ERR "KSDTHR: pos don't work!!!");
//	return POLLERR; //заглушка
//-----------------------------------------------------------------

	//cksdt_dev* dev = pfile->private_data; 

        poll_wait(pfile, &wqksdt, wait); // не верно работает, не ждет (?)

	if(flagksdt)//??
        {	mask |= POLLIN;//| POLLRDNORM; //чтение 
		flagksdt=0;
	}

        //mutex_unlock(&dev->mutex);

        return mask;
}

static struct file_operations fops = {
	.owner	= THIS_MODULE,
	.open = ksdt_open,
	.release = ksdt_release,
	.read = ksdt_read,
	.poll = ksdt_poll,
	.unlocked_ioctl = ksdt_ioctl,
};


static int ksdt_init(void)
{
	int err; 
	err=0;

	printk(KERN_INFO "KSDTHR: START TIMER %d\n",period);

	//выделение номеров устройств динамически-----------------------------------
	/*err = alloc_chrdev_region(&dev_ksdt, 0, COUNT_DEVICES, KSDT_CHDEVNAME);
    	if (err < 0)
    	{
        	printk(KERN_ALERT "KSDTHR: alloc_chrdev_region() error %d\n", err);
        	return FAIL;
	}

	Major = MAJOR(dev_ksdt);
	Minor = MINOR(dev_ksdt);
	printk(KERN_INFO  "KSDTHR: Major,Minor numbers [%d,%d]",Major,Minor);*/

	//новый способ регисtрации------------------------------------------------------
        dev_ksdt = MKDEV(Major,Minor);
        err = register_chrdev_region(dev_ksdt,COUNT_DEVICES,KSDT_CHDEVNAME);// получение номера(ов) символьного устройства

        if(err!=0) 
        {
                printk(KERN_ERR"KSDTHR: Error register_chdev_region for %s code %d\n",KSDT_CHDEVNAME,err);
                unregister_chrdev_region(dev_ksdt, COUNT_DEVICES);
                return err;
        }
	//--------------------------------------------------------------------------------


	ksdt_cdev = &c_dev;

	// mutex_init(&(ksdt_cdev->mutex));


    	//инициализация структуры ksdt_cdev
    	cdev_init(&ksdt_cdev->cdev, &fops);
    	//регистрация структуры
    	if (cdev_add(&ksdt_cdev->cdev, dev_ksdt, COUNT_DEVICES) == -1)
    	{
        	unregister_chrdev_region(dev_ksdt, COUNT_DEVICES);
        	return FAIL;
    	}//*/
	
	return SUCCESS;
}

static void ksdt_cleanup(void)
{
    	unregister_chrdev_region(dev_ksdt,COUNT_DEVICES);
	cdev_del(&ksdt_cdev->cdev);

	printk(KERN_INFO "KSDTHR: STOP TIMER %d\n",period);
}

module_init(ksdt_init);
module_exit(ksdt_cleanup);


