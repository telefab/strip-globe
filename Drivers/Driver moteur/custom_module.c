


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


#define SPEED_BASEADDR 0x43C30000
#define REGION_SIZE 0xFFFF+1


static int speed_major = 0;	/* dynamic by default */
module_param(speed_major, int, 0);


MODULE_AUTHOR ("TELECOM Bretagne");
MODULE_LICENSE("Dual BSD/GPL");

// Virtual Base Address
void *speed_addr;   


//============================================================================
//  /dev/speed file operations
//  read : return the current settings (MODE,SPEED)
//  write: write set the settings (MODE,SPEED)
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
//  - setup motor speed 
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
  request_mem_region(SPEED_BASEADDR, REGION_SIZE, "speed");

  // remap the BASE_ADDR memory region
  speed_addr = ioremap(SPEED_BASEADDR, REGION_SIZE);
  if (speed_addr == NULL) {
    printk(KERN_INFO "speed: erreur ioremap speed\n");
    return -1;
  }
 
  return 0;
}




//============================================================================
// module_cleanup: 
//  - turn the motor off 
//  - unregister the /dev/speed
//  - unmap, and release memory region 
//============================================================================
void cleanup_custom_module(void)
{
  iowrite32(0, speed_addr);
  unregister_chrdev(speed_major, "speed");
  iounmap(speed_addr);
  release_mem_region(SPEED_BASEADDR, REGION_SIZE);
  printk(KERN_INFO "speed: module cleaned ...\n");
}


int init_custom_module(void)
{
  int result;

  printk(KERN_INFO "Custom Module init..\n");
  result = speed_init();
  if (result !=0) return result;

  printk(KERN_INFO "Custom Module:init done\n");
  return 0;
}



module_init(init_custom_module);
module_exit(cleanup_custom_module);