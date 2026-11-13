# App-specific R8 rules. Flutter and plugins supply their own consumer rules.
# Retain metadata used by annotations and reflective integrations without
# disabling shrinking or suppressing missing-class diagnostics globally.
-keepattributes Signature,InnerClasses,EnclosingMethod,*Annotation*
