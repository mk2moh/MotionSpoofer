TARGET := iphone:clang:latest:15.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = MotionSpooferPrefs
MotionSpooferPrefs_FILES = RootListController.m AdvancedListController.m
MotionSpooferPrefs_FRAMEWORKS = UIKit
MotionSpooferPrefs_PRIVATE_FRAMEWORKS = Preferences
MotionSpooferPrefs_INSTALL_PATH = /Library/PreferenceBundles
MotionSpooferPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
