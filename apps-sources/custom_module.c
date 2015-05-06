


#include <linux/kernel.h>
#include <linux/module.h>
#include <asm/uaccess.h>	// copy_from_user 
#include <asm/io.h>		// IO Read/Write Functions
#include <linux/proc_fs.h>	// Proc File System Functions
#include <linux/seq_file.h>	// Sequence File Operations
#include <linux/ioport.h>	// release_mem_region
#include <linux/interrupt.h>	// interrupt 
#include <linux/irq.h>	
#include <linux/wait.h>
#include <linux/sched.h>

// Addresses and sizes of the 
#define SPEED_BASEADDR 0x43C34B00
#define SPEED_SIZE 0xFFFF+1
#define RND_BASEADDR 0x43C34B08
#define RND_SIZE 0xFFFF+1
#define CNTRL_BASEADDR 0x43C34B04
#define CNTRL_SIZE 0xFFFF+1
#define CHAR_BASEADDR 0x43C34B0C


static int speed_major = 0;
module_param(speed_major, int, 0);

static int rnd_major = 0;
module_param(rnd_major, int, 0);

static int cntrl_major = 0;
module_param(cntrl_major, int, 0);


MODULE_AUTHOR ("TELECOM Bretagne");
MODULE_LICENSE("Dual BSD/GPL");

// Virtual Base Address
void *speed_addr; 
void *rnd_addr;  
void *cntrl_addr;


//============================================================================
//  /dev/speed file operations
//  read : return the current setting speed
//  write: write set the setting speed
//============================================================================
int speed_i_open (struct inode *inode, struct file *filp)
{
  printk(KERN_INFO "speed: device opened.\n");
  return 0;
}

int speed_i_release (struct inode *inode, struct file *filp)
{ 
  printk(KERN_INFO "speed: device closed\n");
  return 0;
}

ssize_t speed_i_read (struct file *filp, char __user *buf, size_t count, loff_t *f_pos)
{
  char result[1];
  printk(KERN_INFO "speed: device read\n");
  result[0]=ioread8(speed_addr);
  if (copy_to_user(buf, result, 1))
    return -EFAULT;
  return 0;
}

ssize_t speed_i_write (struct file *filp, const char __user *buf, size_t count,	loff_t *f_pos)
{
  char cmd[1];		
  if(copy_from_user(cmd, buf, count))
    return -EINVAL;
  iowrite8(cmd[0],speed_addr);

  return count;
}

struct file_operations speed_i_fops = {
	.owner	 = THIS_MODULE,
	.read	 = speed_i_read,
	.write	 = speed_i_write,
	.open	 = speed_i_open,
	.release = speed_i_release,
};


//============================================================================
// speed_init: 
//  - setup /dev/speed device
//  - protect the memory region 
//  - io-remap the device BASE_ADDR
//============================================================================
int speed_init(void)
{
  int result;
 
  // register our device
  result = register_chrdev(speed_major, "speed", &speed_i_fops);
  if (result < 0) {
    printk(KERN_INFO "speed: can't get major number\n");
    return result;
  }
  
  // if the major number isn't fix, the major is dynamic 
  if (speed_major == 0) 
    speed_major = result;

  // protect the memory region 
  request_mem_region(SPEED_BASEADDR, SPEED_SIZE, "speed");

  // remap the BASE_ADDR memory region
  speed_addr = ioremap(SPEED_BASEADDR, SPEED_SIZE);
  if (speed_addr == NULL) {
    printk(KERN_INFO "speed: erreur ioremap speed\n");
    return -1;
  }
 
  return 0;
}

//============================================================================
//  /dev/rnd file operations
//  read : return the real rotating speed of the globe
//============================================================================
int rnd_i_open (struct inode *inode, struct file *filp)
{
  printk(KERN_INFO "rnd: device opened.\n");
  return 0;
}

int rnd_i_release (struct inode *inode, struct file *filp)
{ 
  printk(KERN_INFO "rnd: device closed\n");
  return 0;
}

ssize_t rnd_i_read (struct file *filp, char __user *buf, size_t count, loff_t *f_pos)
{
  char result[3];
  printk(KERN_INFO "rnd: device read\n");
    unsigned int cal;
    cal = ioread32(rnd_addr);
    result[0] = (char) (cal & 0xFF);
    result[1] = (char) ((cal & 0xFF00) >> 8);
    result[2] = (char) ((cal & 0xFF0000) >> 16);   
  if (copy_to_user(buf, result, 3))
    return -EFAULT;
  return 0;
}

ssize_t rnd_i_write (struct file *filp, const char __user *buf, size_t count,	loff_t *f_pos)
{
  return count;
}

struct file_operations rnd_i_fops = {
	.owner	 = THIS_MODULE,
	.read	 = rnd_i_read,
	.write	 = rnd_i_write,
	.open	 = rnd_i_open,
	.release = rnd_i_release,
};



//============================================================================
// rnd_init: 
//  - setup /dev/rnd device
//  - protect the memory region 
//  - io-remap the device BASE_ADDR
//============================================================================
int rnd_init(void)
{
  int result;
 
  // register our device
  result = register_chrdev(rnd_major, "rnd", &rnd_i_fops);
  if (result < 0) {
    printk(KERN_INFO "rnd: can't get major number\n");
    return result;
  }
  
  // if the major number isn't fix, the major is dynamic 
  if (rnd_major == 0) 
    rnd_major = result;

  // protect the memory region 
  request_mem_region(RND_BASEADDR, RND_SIZE, "rnd");

  // remap the BASE_ADDR memory region
  rnd_addr = ioremap(RND_BASEADDR, RND_SIZE);
  if (rnd_addr == NULL) {
    printk(KERN_INFO "rnd: erreur ioremap speed\n");
    return -1;
  }
 
  return 0;
}


//============================================================================
//  /dev/cntrl file operations
//  read : return the current control settings (ROT_ENABLE,CHAR_ENABLE,COPY,PS_CONTROL,RAM_ENABLE,WR1,WR0)
//  write: write set the control settings (ROT_ENABLE,CHAR_ENABLE,COPY,PS_CONTROL,RAM_ENABLE,WR1,WR0)
//============================================================================
int cntrl_i_open (struct inode *inode, struct file *filp)
{
  printk(KERN_INFO "cntrl: device opened.\n");
  return 0;
}

int cntrl_i_release (struct inode *inode, struct file *filp)
{ 
  printk(KERN_INFO "cntrl: device closed\n");
  return 0;
}

ssize_t cntrl_i_read (struct file *filp, char __user *buf, size_t count, loff_t *f_pos)
{
  char result[1];
  printk(KERN_INFO "cntrl: device read\n");
  result[0]=ioread8(cntrl_addr);
  if (copy_to_user(buf, result, 1))
    return -EFAULT;
  return 0;
}

ssize_t cntrl_i_write (struct file *filp, const char __user *buf, size_t count,	loff_t *f_pos)
{
  char cmd[1];		
  if(copy_from_user(cmd, buf, count))
    return -EINVAL;
  iowrite8(cmd[0],cntrl_addr);

  return count;
}

struct file_operations cntrl_i_fops = {
	.owner	 = THIS_MODULE,
	.read	 = cntrl_i_read,
	.write	 = cntrl_i_write,
	.open	 = cntrl_i_open,
	.release = cntrl_i_release,
};


//============================================================================
// cntrl_init: 
//  - setup /dev/cntrl device
//  - protect the memory region 
//  - io-remap the device BASE_ADDR 
//============================================================================
int cntrl_init(void)
{
  int result;
 
  // register our device
  result = register_chrdev(cntrl_major, "cntrl", &cntrl_i_fops);
  if (result < 0) {
    printk(KERN_INFO "cntrl: can't get major number\n");
    return result;
  }
  
  // if the major number isn't fix, the major is dynamic 
  if (cntrl_major == 0) 
    cntrl_major = result;

  // protect the memory region 
  request_mem_region(CNTRL_BASEADDR, CNTRL_SIZE, "cntrl");

  // remap the BASE_ADDR memory region
  cntrl_addr = ioremap(CNTRL_BASEADDR, CNTRL_SIZE);
  if (cntrl_addr == NULL) {
    printk(KERN_INFO "cntrl: erreur ioremap cntrl\n");
    return -1;
  }
 
  return 0;
}



//============================================================================
// module_cleanup: 
//  - turn the motor off 
//  - unregister the /dev/speed, /dev/cntrl, /dev/rnd
//  - unmap, and release memory region 
//============================================================================
void cleanup_custom_module(void)
{
  iowrite8(0, speed_addr);
  unregister_chrdev(speed_major, "speed");
  unregister_chrdev(rnd_major, "rnd");
  unregister_chrdev(cntrl_major, "cntrl");
  iounmap(speed_addr);
  iounmap(rnd_addr);
  iounmap(cntrl_addr);
  release_mem_region(SPEED_BASEADDR, SPEED_SIZE);
  release_mem_region(RND_BASEADDR, RND_SIZE);
  release_mem_region(CNTRL_BASEADDR, CNTRL_SIZE);
  printk(KERN_INFO "cntrl: module cleaned ...\n");
}


int init_custom_module(void)
{
  int result;

  printk(KERN_INFO "Custom Module init..\n");
  result = speed_init();
  if (result !=0) return result;
  
  result = rnd_init();
  if (result !=0) return result;
  
  result = cntrl_init();
  if (result !=0) return result;

  printk(KERN_INFO "Custom Module:init done\n");
  return 0;
}



module_init(init_custom_module);
module_exit(cleanup_custom_module);
