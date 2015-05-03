################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include src/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
ELFSIZE += \
zybo_globe_fsbl.elf.size \


# All Target
all: zybo_globe_fsbl.elf secondary-outputs

# Tool invocations
zybo_globe_fsbl.elf: $(OBJS) ../src/lscript.ld $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: ARM gcc linker'
	arm-xilinx-eabi-gcc -L"/home/phhorrei/perso/fablab/zybo_globe/source/vivado/hw/zybo_bsd/zybo_bsd.sdk/zybo_globe_fsbl/src" -Wl,-T -Wl,../src/lscript.ld -L../../zybo_globe_fsbl_bsp/ps7_cortexa9_0/lib -o "zybo_globe_fsbl.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

zybo_globe_fsbl.elf.size: zybo_globe_fsbl.elf
	@echo 'Invoking: ARM Print Size'
	arm-xilinx-eabi-size zybo_globe_fsbl.elf  |tee "zybo_globe_fsbl.elf.size"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(EXECUTABLES)$(OBJS)$(S_UPPER_DEPS)$(C_DEPS)$(ELFSIZE) zybo_globe_fsbl.elf
	-@echo ' '

secondary-outputs: $(ELFSIZE)

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets
