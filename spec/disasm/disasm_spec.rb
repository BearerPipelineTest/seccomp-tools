# encoding: ascii-8bit
# frozen_string_literal: true

require 'seccomp-tools/disasm/disasm'
require 'seccomp-tools/util'

describe SeccompTools::Disasm do
  before do
    SeccompTools::Util.disable_color!
  end

  it 'normal' do
    bpf = File.binread(File.join(__dir__, '..', 'data', 'twctf-2016-diary.bpf'))
    expect(described_class.disasm(bpf, arch: :amd64)).to eq <<-EOS
 line  CODE  JT   JF      K
=================================
 0000: 0x20 0x00 0x00 0x00000000  A = sys_number
 0001: 0x15 0x00 0x01 0x00000002  if (A != open) goto 0003
 0002: 0x06 0x00 0x00 0x00000000  return KILL
 0003: 0x15 0x00 0x01 0x00000101  if (A != openat) goto 0005
 0004: 0x06 0x00 0x00 0x00000000  return KILL
 0005: 0x15 0x00 0x01 0x0000003b  if (A != execve) goto 0007
 0006: 0x06 0x00 0x00 0x00000000  return KILL
 0007: 0x15 0x00 0x01 0x00000038  if (A != clone) goto 0009
 0008: 0x06 0x00 0x00 0x00000000  return KILL
 0009: 0x15 0x00 0x01 0x00000039  if (A != fork) goto 0011
 0010: 0x06 0x00 0x00 0x00000000  return KILL
 0011: 0x15 0x00 0x01 0x0000003a  if (A != vfork) goto 0013
 0012: 0x06 0x00 0x00 0x00000000  return KILL
 0013: 0x15 0x00 0x01 0x00000055  if (A != creat) goto 0015
 0014: 0x06 0x00 0x00 0x00000000  return KILL
 0015: 0x15 0x00 0x01 0x00000142  if (A != execveat) goto 0017
 0016: 0x06 0x00 0x00 0x00000000  return KILL
 0017: 0x06 0x00 0x00 0x7fff0000  return ALLOW
    EOS
  end

  it 'libseccomp' do
    bpf = File.binread(File.join(__dir__, '..', 'data', 'libseccomp.bpf'))
    expect(described_class.disasm(bpf, arch: :amd64)).to eq <<-EOS
 line  CODE  JT   JF      K
=================================
 0000: 0x20 0x00 0x00 0x00000004  A = arch
 0001: 0x15 0x00 0x08 0xc000003e  if (A != ARCH_X86_64) goto 0010
 0002: 0x20 0x00 0x00 0x00000000  A = sys_number
 0003: 0x35 0x06 0x00 0x40000000  if (A >= 0x40000000) goto 0010
 0004: 0x15 0x04 0x00 0x00000001  if (A == write) goto 0009
 0005: 0x15 0x03 0x00 0x00000003  if (A == close) goto 0009
 0006: 0x15 0x02 0x00 0x00000020  if (A == dup) goto 0009
 0007: 0x15 0x01 0x00 0x0000003c  if (A == exit) goto 0009
 0008: 0x06 0x00 0x00 0x00050005  return ERRNO(5)
 0009: 0x06 0x00 0x00 0x7fff0000  return ALLOW
 0010: 0x06 0x00 0x00 0x00000000  return KILL
    EOS
  end

  it 'i386' do
    bpf = File.binread(File.join(__dir__, '..', 'data', 'CONFidence-2017-amigo.bpf'))
    expect(described_class.disasm(bpf, arch: :i386)).to eq <<-EOS
 line  CODE  JT   JF      K
=================================
 0000: 0x20 0x00 0x00 0x00000004  A = arch
 0001: 0x15 0x00 0x01 0x40000003  if (A != ARCH_I386) goto 0003
 0002: 0x05 0x00 0x00 0x0000000a  goto 0013
 0003: 0x20 0x00 0x00 0x00000038  A = args[5]
 0004: 0x02 0x00 0x00 0x00000000  mem[0] = A
 0005: 0x20 0x00 0x00 0x0000003c  A = args[5] >> 32
 0006: 0x02 0x00 0x00 0x00000001  mem[1] = A
 0007: 0x15 0x00 0x03 0x03133731  if (A != 0x3133731) goto 0011
 0008: 0x60 0x00 0x00 0x00000000  A = mem[0]
 0009: 0x15 0x02 0x00 0x33731337  if (A == 0x33731337) goto 0012
 0010: 0x60 0x00 0x00 0x00000001  A = mem[1]
 0011: 0x06 0x00 0x00 0x00000000  return KILL
 0012: 0x60 0x00 0x00 0x00000001  A = mem[1]
 0013: 0x05 0x00 0x00 0x00000000  goto 0014
 0014: 0x20 0x00 0x00 0x00000000  A = sys_number
 0015: 0x15 0x00 0x01 0x000003e7  if (A != 0x3e7) goto 0017
 0016: 0x06 0x00 0x00 0x0005053b  return ERRNO(1339)
 0017: 0x15 0x00 0x01 0x00000004  if (A != write) goto 0019
 0018: 0x06 0x00 0x00 0x7fff0000  return ALLOW
 0019: 0x15 0x00 0x01 0x00000092  if (A != writev) goto 0021
 0020: 0x06 0x00 0x00 0x7fff0000  return ALLOW
 0021: 0x15 0x00 0x01 0x00000003  if (A != read) goto 0023
 0022: 0x06 0x00 0x00 0x7fff0000  return ALLOW
 0023: 0x15 0x00 0x01 0x000000c5  if (A != fstat64) goto 0025
 0024: 0x06 0x00 0x00 0x7fff0000  return ALLOW
 0025: 0x15 0x00 0x01 0x0000008c  if (A != _llseek) goto 0027
 0026: 0x06 0x00 0x00 0x7fff0000  return ALLOW
 0027: 0x15 0x00 0x01 0x000000fc  if (A != exit_group) goto 0029
 0028: 0x06 0x00 0x00 0x7fff0000  return ALLOW
 0029: 0x15 0x00 0x01 0x000000c0  if (A != mmap2) goto 0031
 0030: 0x06 0x00 0x00 0x7fff0000  return ALLOW
 0031: 0x15 0x00 0x01 0x000000af  if (A != rt_sigprocmask) goto 0033
 0032: 0x06 0x00 0x00 0x7fff0000  return ALLOW
 0033: 0x15 0x00 0x01 0x000000ae  if (A != rt_sigaction) goto 0035
 0034: 0x06 0x00 0x00 0x7fff0000  return ALLOW
 0035: 0x15 0x00 0x01 0x0000002d  if (A != brk) goto 0037
 0036: 0x06 0x00 0x00 0x7fff0000  return ALLOW
 0037: 0x15 0x00 0x01 0x00000025  if (A != kill) goto 0039
 0038: 0x05 0x00 0x00 0x0000000f  goto 0054
 0039: 0x15 0x00 0x01 0x00000101  if (A != remap_file_pages) goto 0041
 0040: 0x05 0x00 0x00 0x00000023  goto 0076
 0041: 0x15 0x00 0x01 0x0000010e  if (A != tgkill) goto 0043
 0042: 0x06 0x00 0x00 0x00050000  return ERRNO(0)
 0043: 0x15 0x00 0x01 0x00000005  if (A != open) goto 0045
 0044: 0x06 0x00 0x00 0x0005007e  return ERRNO(126)
 0045: 0x15 0x00 0x01 0x00000088  if (A != personality) goto 0047
 0046: 0x06 0x00 0x00 0x0005007e  return ERRNO(126)
 0047: 0x15 0x00 0x01 0x00000014  if (A != getpid) goto 0049
 0048: 0x06 0x00 0x00 0x00050539  return ERRNO(1337)
 0049: 0x15 0x00 0x01 0x000000e0  if (A != gettid) goto 0051
 0050: 0x06 0x00 0x00 0x00050539  return ERRNO(1337)
 0051: 0x15 0x00 0x01 0x00000038  if (A != mpx) goto 0053
 0052: 0x06 0x00 0x00 0x7ff00000  return TRACE
 0053: 0x06 0x00 0x00 0x00000000  return KILL
 0054: 0x05 0x00 0x00 0x00000000  goto 0055
 0055: 0x20 0x00 0x00 0x00000010  A = pid # kill(pid, sig)
 0056: 0x02 0x00 0x00 0x00000000  mem[0] = A
 0057: 0x20 0x00 0x00 0x00000014  A = pid >> 32 # kill(pid, sig)
 0058: 0x02 0x00 0x00 0x00000001  mem[1] = A
 0059: 0x15 0x00 0x03 0x00000000  if (A != 0x0) goto 0063
 0060: 0x60 0x00 0x00 0x00000000  A = mem[0]
 0061: 0x15 0x02 0x00 0x00001d93  if (A == 0x1d93) goto 0064
 0062: 0x60 0x00 0x00 0x00000001  A = mem[1]
 0063: 0x06 0x00 0x00 0x00000000  return KILL
 0064: 0x60 0x00 0x00 0x00000001  A = mem[1]
 0065: 0x20 0x00 0x00 0x00000018  A = sig # kill(pid, sig)
 0066: 0x02 0x00 0x00 0x00000000  mem[0] = A
 0067: 0x20 0x00 0x00 0x0000001c  A = sig >> 32 # kill(pid, sig)
 0068: 0x02 0x00 0x00 0x00000001  mem[1] = A
 0069: 0x15 0x00 0x03 0x00000000  if (A != 0x0) goto 0073
 0070: 0x60 0x00 0x00 0x00000000  A = mem[0]
 0071: 0x15 0x02 0x00 0x00000013  if (A == 0x13) goto 0074
 0072: 0x60 0x00 0x00 0x00000001  A = mem[1]
 0073: 0x06 0x00 0x00 0x00000000  return KILL
 0074: 0x60 0x00 0x00 0x00000001  A = mem[1]
 0075: 0x06 0x00 0x00 0x7fff0000  return ALLOW
 0076: 0x05 0x00 0x00 0x00000000  goto 0077
 0077: 0x20 0x00 0x00 0x00000010  A = start # remap_file_pages(start, size, prot, pgoff, flags)
 0078: 0x02 0x00 0x00 0x00000000  mem[0] = A
 0079: 0x20 0x00 0x00 0x00000014  A = start >> 32 # remap_file_pages(start, size, prot, pgoff, flags)
 0080: 0x02 0x00 0x00 0x00000001  mem[1] = A
 0081: 0x15 0x00 0x03 0xffffffff  if (A != 0xffffffff) goto 0085
 0082: 0x60 0x00 0x00 0x00000000  A = mem[0]
 0083: 0x15 0x02 0x00 0xffffff9c  if (A == 0xffffff9c) goto 0086
 0084: 0x60 0x00 0x00 0x00000001  A = mem[1]
 0085: 0x06 0x00 0x00 0x00000000  return KILL
 0086: 0x60 0x00 0x00 0x00000001  A = mem[1]
 0087: 0x20 0x00 0x00 0x00000020  A = prot # remap_file_pages(start, size, prot, pgoff, flags)
 0088: 0x02 0x00 0x00 0x00000000  mem[0] = A
 0089: 0x20 0x00 0x00 0x00000024  A = prot >> 32 # remap_file_pages(start, size, prot, pgoff, flags)
 0090: 0x02 0x00 0x00 0x00000001  mem[1] = A
 0091: 0x15 0x00 0x03 0x12345678  if (A != 0x12345678) goto 0095
 0092: 0x60 0x00 0x00 0x00000000  A = mem[0]
 0093: 0x15 0x02 0x00 0x00000000  if (A == 0x0) goto 0096
 0094: 0x60 0x00 0x00 0x00000001  A = mem[1]
 0095: 0x06 0x00 0x00 0x00000000  return KILL
 0096: 0x60 0x00 0x00 0x00000001  A = mem[1]
 0097: 0x06 0x00 0x00 0x7fff0000  return ALLOW
    EOS
  end

  it 'aarch64' do
    bpf = File.binread(File.join(__dir__, '..', 'data', 'DEF-CON-2020-bdooos.bpf'))
    expect(described_class.disasm(bpf, arch: :aarch64)).to eq <<-EOS
 line  CODE  JT   JF      K
=================================
 0000: 0x20 0x00 0x00 0x00000004  A = arch
 0001: 0x15 0x00 0x10 0xc00000b7  if (A != ARCH_AARCH64) goto 0018
 0002: 0x20 0x00 0x00 0x00000000  A = sys_number
 0003: 0x15 0x0d 0x00 0x0000001d  if (A == ioctl) goto 0017
 0004: 0x15 0x0c 0x00 0x0000003f  if (A == read) goto 0017
 0005: 0x15 0x0b 0x00 0x00000040  if (A == write) goto 0017
 0006: 0x15 0x0a 0x00 0x00000049  if (A == ppoll) goto 0017
 0007: 0x15 0x09 0x00 0x0000005e  if (A == exit_group) goto 0017
 0008: 0x15 0x08 0x00 0x00000062  if (A == futex) goto 0017
 0009: 0x15 0x07 0x00 0x00000084  if (A == sigaltstack) goto 0017
 0010: 0x15 0x06 0x00 0x00000086  if (A == rt_sigaction) goto 0017
 0011: 0x15 0x05 0x00 0x0000008b  if (A == rt_sigreturn) goto 0017
 0012: 0x15 0x04 0x00 0x000000ce  if (A == sendto) goto 0017
 0013: 0x15 0x03 0x00 0x000000cf  if (A == recvfrom) goto 0017
 0014: 0x15 0x02 0x00 0x000000d0  if (A == setsockopt) goto 0017
 0015: 0x15 0x01 0x00 0x000000d7  if (A == munmap) goto 0017
 0016: 0x06 0x00 0x00 0x80000000  return KILL_PROCESS
 0017: 0x06 0x00 0x00 0x7fff0000  return ALLOW
 0018: 0x06 0x00 0x00 0x00000000  return KILL
    EOS
  end

  it 'x32 syscall and args' do
    bpf = File.binread(File.join(__dir__, '..', 'data', 'x32.bpf'))
    expect(described_class.disasm(bpf, arch: :amd64)).to eq <<-EOS
 line  CODE  JT   JF      K
=================================
 0000: 0x20 0x00 0x00 0x00000004  A = arch
 0001: 0x15 0x00 0x09 0xc000003e  if (A != ARCH_X86_64) goto 0011
 0002: 0x20 0x00 0x00 0x00000000  A = sys_number
 0003: 0x35 0x00 0x07 0x40000000  if (A < 0x40000000) goto 0011
 0004: 0x15 0x06 0x00 0x40000000  if (A == x32_read) goto 0011
 0005: 0x15 0x05 0x00 0x40000001  if (A == x32_write) goto 0011
 0006: 0x15 0x04 0x00 0x400000ac  if (A == x32_iopl) goto 0011
 0007: 0x15 0x00 0x03 0x40000009  if (A != x32_mmap) goto 0011
 0008: 0x20 0x00 0x00 0x00000010  A = addr # x32_mmap(addr, len, prot, flags, fd, pgoff)
 0009: 0x15 0x01 0x00 0x00000000  if (A == 0x0) goto 0011
 0010: 0x06 0x00 0x00 0x00050005  return ERRNO(5)
 0011: 0x06 0x00 0x00 0x7fff0000  return ALLOW
    EOS
  end

  it 'syscall args' do
    bpf = File.binread(File.join(__dir__, '..', 'data', 'gctf-2019-quals-caas.bpf'))
    expect(described_class.disasm(bpf, arch: :amd64)).to eq <<-EOS
 line  CODE  JT   JF      K
=================================
 0000: 0x20 0x00 0x00 0x00000004  A = arch
 0001: 0x15 0x00 0x3c 0xc000003e  if (A != ARCH_X86_64) goto 0062
 0002: 0x20 0x00 0x00 0x00000000  A = sys_number
 0003: 0x35 0x3a 0x00 0x40000000  if (A >= 0x40000000) goto 0062
 0004: 0x15 0x38 0x00 0x00000000  if (A == read) goto 0061
 0005: 0x15 0x37 0x00 0x00000001  if (A == write) goto 0061
 0006: 0x15 0x36 0x00 0x00000003  if (A == close) goto 0061
 0007: 0x15 0x35 0x00 0x0000000b  if (A == munmap) goto 0061
 0008: 0x15 0x34 0x00 0x00000018  if (A == sched_yield) goto 0061
 0009: 0x15 0x33 0x00 0x00000020  if (A == dup) goto 0061
 0010: 0x15 0x32 0x00 0x00000021  if (A == dup2) goto 0061
 0011: 0x15 0x31 0x00 0x00000023  if (A == nanosleep) goto 0061
 0012: 0x15 0x30 0x00 0x0000002a  if (A == connect) goto 0061
 0013: 0x15 0x2f 0x00 0x0000002b  if (A == accept) goto 0061
 0014: 0x15 0x2e 0x00 0x0000002f  if (A == recvmsg) goto 0061
 0015: 0x15 0x2d 0x00 0x00000031  if (A == bind) goto 0061
 0016: 0x15 0x2c 0x00 0x0000003c  if (A == exit) goto 0061
 0017: 0x15 0x2b 0x00 0x000000e7  if (A == exit_group) goto 0061
 0018: 0x15 0x00 0x04 0x00000038  if (A != clone) goto 0023
 0019: 0x20 0x00 0x00 0x00000014  A = clone_flags >> 32 # clone(clone_flags, newsp, parent_tidptr, child_tidptr, tls)
 0020: 0x15 0x00 0x29 0x00000000  if (A != 0x0) goto 0062
 0021: 0x20 0x00 0x00 0x00000010  A = clone_flags # clone(clone_flags, newsp, parent_tidptr, child_tidptr, tls)
 0022: 0x15 0x26 0x27 0x00010900  if (A == 0x10900) goto 0061 else goto 0062
 0023: 0x15 0x00 0x0c 0x00000029  if (A != socket) goto 0036
 0024: 0x20 0x00 0x00 0x00000014  A = family >> 32 # socket(family, type, protocol)
 0025: 0x15 0x00 0x24 0x00000000  if (A != 0x0) goto 0062
 0026: 0x20 0x00 0x00 0x00000010  A = family # socket(family, type, protocol)
 0027: 0x15 0x00 0x22 0x00000002  if (A != 0x2) goto 0062
 0028: 0x20 0x00 0x00 0x0000001c  A = type >> 32 # socket(family, type, protocol)
 0029: 0x15 0x00 0x20 0x00000000  if (A != 0x0) goto 0062
 0030: 0x20 0x00 0x00 0x00000018  A = type # socket(family, type, protocol)
 0031: 0x15 0x00 0x1e 0x00000001  if (A != 0x1) goto 0062
 0032: 0x20 0x00 0x00 0x00000024  A = protocol >> 32 # socket(family, type, protocol)
 0033: 0x15 0x00 0x1c 0x00000000  if (A != 0x0) goto 0062
 0034: 0x20 0x00 0x00 0x00000020  A = protocol # socket(family, type, protocol)
 0035: 0x15 0x19 0x1a 0x00000000  if (A == 0x0) goto 0061 else goto 0062
 0036: 0x15 0x00 0x19 0x00000009  if (A != mmap) goto 0062
 0037: 0x20 0x00 0x00 0x00000014  A = addr >> 32 # mmap(addr, len, prot, flags, fd, pgoff)
 0038: 0x15 0x00 0x17 0x00000000  if (A != 0x0) goto 0062
 0039: 0x20 0x00 0x00 0x00000010  A = addr # mmap(addr, len, prot, flags, fd, pgoff)
 0040: 0x15 0x00 0x15 0x00000000  if (A != 0x0) goto 0062
 0041: 0x20 0x00 0x00 0x0000001c  A = len >> 32 # mmap(addr, len, prot, flags, fd, pgoff)
 0042: 0x15 0x00 0x13 0x00000000  if (A != 0x0) goto 0062
 0043: 0x20 0x00 0x00 0x00000018  A = len # mmap(addr, len, prot, flags, fd, pgoff)
 0044: 0x15 0x00 0x11 0x00001000  if (A != 0x1000) goto 0062
 0045: 0x20 0x00 0x00 0x00000024  A = prot >> 32 # mmap(addr, len, prot, flags, fd, pgoff)
 0046: 0x15 0x00 0x0f 0x00000000  if (A != 0x0) goto 0062
 0047: 0x20 0x00 0x00 0x00000020  A = prot # mmap(addr, len, prot, flags, fd, pgoff)
 0048: 0x15 0x00 0x0d 0x00000003  if (A != 0x3) goto 0062
 0049: 0x20 0x00 0x00 0x0000002c  A = flags >> 32 # mmap(addr, len, prot, flags, fd, pgoff)
 0050: 0x15 0x00 0x0b 0x00000000  if (A != 0x0) goto 0062
 0051: 0x20 0x00 0x00 0x00000028  A = flags # mmap(addr, len, prot, flags, fd, pgoff)
 0052: 0x15 0x00 0x09 0x00000022  if (A != 0x22) goto 0062
 0053: 0x20 0x00 0x00 0x00000034  A = fd >> 32 # mmap(addr, len, prot, flags, fd, pgoff)
 0054: 0x15 0x00 0x07 0x00000000  if (A != 0x0) goto 0062
 0055: 0x20 0x00 0x00 0x00000030  A = fd # mmap(addr, len, prot, flags, fd, pgoff)
 0056: 0x15 0x00 0x05 0x00000000  if (A != 0x0) goto 0062
 0057: 0x20 0x00 0x00 0x0000003c  A = pgoff >> 32 # mmap(addr, len, prot, flags, fd, pgoff)
 0058: 0x15 0x00 0x03 0x00000000  if (A != 0x0) goto 0062
 0059: 0x20 0x00 0x00 0x00000038  A = pgoff # mmap(addr, len, prot, flags, fd, pgoff)
 0060: 0x15 0x00 0x01 0x00000000  if (A != 0x0) goto 0062
 0061: 0x06 0x00 0x00 0x7fff0000  return ALLOW
 0062: 0x06 0x00 0x00 0x00000000  return KILL
    EOS
  end

  it 'args of unknown syscall' do
    bpf = "\x20\x00\x00\x00\x00\x00\x00\x00" \
          "\x15\x00\x00\x01\xE7\x03\x00\x00" \
          "\x20\x00\x00\x00\x10\x00\x00\x00" \
          "\x06\x00\x00\x00\x00\x00\x00\x00"
    expect(described_class.disasm(bpf, arch: :amd64)).to eq <<-EOS
 line  CODE  JT   JF      K
=================================
 0000: 0x20 0x00 0x00 0x00000000  A = sys_number
 0001: 0x15 0x00 0x01 0x000003e7  if (A != 0x3e7) goto 0003
 0002: 0x20 0x00 0x00 0x00000010  A = args[0]
 0003: 0x06 0x00 0x00 0x00000000  return KILL
    EOS
  end

  it 'all instructions' do
    bpf = File.binread(File.join(__dir__, '..', 'data', 'all_inst.bpf'))
    expect(described_class.disasm(bpf, arch: :amd64)).to eq <<-EOS
 line  CODE  JT   JF      K
=================================
 0000: 0x20 0x00 0x00 0x00000000  A = sys_number
 0001: 0x20 0x00 0x00 0x00000004  A = arch
 0002: 0x20 0x00 0x00 0x00000008  A = instruction_pointer
 0003: 0x20 0x00 0x00 0x00000010  A = args[0]
 0004: 0x20 0x00 0x00 0x00000018  A = args[1]
 0005: 0x20 0x00 0x00 0x00000020  A = args[2]
 0006: 0x20 0x00 0x00 0x00000028  A = args[3]
 0007: 0x20 0x00 0x00 0x00000030  A = args[4]
 0008: 0x20 0x00 0x00 0x00000038  A = args[5]
 0009: 0x80 0xb7 0x1f 0x00000016  A = 64
 0010: 0x81 0xfd 0xbd 0x00000067  X = 64
 0011: 0x06 0xb9 0xcf 0x0000008c  return KILL
 0012: 0x16 0x4f 0x67 0x000000cc  return A
 0013: 0x04 0x1a 0xc5 0x00000028  A += 0x28
 0014: 0x0c 0xd4 0x2f 0x000000a8  A += X
 0015: 0x14 0xa8 0xe7 0x000000db  A -= 0xdb
 0016: 0x1c 0x5d 0xd6 0x000000e0  A -= X
 0017: 0x24 0x3d 0x0e 0x00000052  A *= 0x52
 0018: 0x2c 0x57 0xaf 0x000000f2  A *= X
 0019: 0x34 0x9f 0x5a 0x000000ee  A /= 0xee
 0020: 0x3c 0x48 0x2c 0x00000042  A /= X
 0021: 0x54 0xf6 0x8f 0x000000ac  A &= 0xac
 0022: 0x5c 0x61 0xc8 0x00000017  A &= X
 0023: 0x44 0x81 0x0a 0x000000ef  A |= 0xef
 0024: 0x4c 0x45 0xc9 0x000000b3  A |= X
 0025: 0xa4 0x1c 0x40 0x0000009e  A ^= 0x9e
 0026: 0xac 0x61 0xc1 0x0000008f  A ^= X
 0027: 0x64 0xde 0x38 0x000000bb  A <<= 187
 0028: 0x6c 0x05 0x07 0x000000f1  A <<= X
 0029: 0x74 0x34 0xde 0x0000003b  A >>= 59
 0030: 0x7c 0xe2 0xc7 0x000000cb  A >>= X
 0031: 0x84 0xce 0x78 0x00000034  A = -A
 0032: 0x00 0x46 0x02 0x000000c2  A = 194
 0033: 0x01 0xe3 0xd4 0x000000a6  X = 166
 0034: 0x07 0x80 0x93 0x0000003d  X = A
 0035: 0x87 0x17 0x1a 0x0000007c  A = X
 0036: 0x60 0x10 0xa1 0x0000000d  A = mem[13]
 0037: 0x61 0x89 0xed 0x00000050  X = mem[80]
 0038: 0x02 0x18 0x9f 0x00000022  mem[34] = A
 0039: 0x03 0xe9 0xf5 0x0000008a  mem[138] = X
 0040: 0x05 0x08 0xb2 0x00000031  goto 0090
 0041: 0x15 0x06 0xc6 0x000000f7  if (A == 247) goto 0048 else goto 0240
 0042: 0x1d 0x9e 0x89 0x00000091  if (A == X) goto 0201 else goto 0180
 0043: 0x35 0x9a 0xa8 0x0000009e  if (A >= 158) goto 0198 else goto 0212
 0044: 0x3d 0x03 0x29 0x0000009a  if (A >= X) goto 0048 else goto 0086
 0045: 0x25 0x02 0x13 0x000000ce  if (A > 206) goto 0048 else goto 0065
 0046: 0x2d 0x06 0x68 0x00000005  if (A > X) goto 0053 else goto 0151
 0047: 0x45 0x08 0x9b 0x0000004d  if (A & 77) goto 0056 else goto 0203
 0048: 0x4d 0x1a 0x61 0x000000bf  if (A & X) goto 0075 else goto 0146
    EOS
  end

  it 'test branch function' do
    raw = File.binread(File.join(__dir__, '..', 'data', 'misc_alu.bpf'))
    expect(described_class.disasm(raw, arch: :amd64)).to eq(<<-EOS)
 line  CODE  JT   JF      K
=================================
 0000: 0x20 0x00 0x00 0x00000008  A = instruction_pointer
 0001: 0x07 0x00 0x00 0x00000000  X = A
 0002: 0x20 0x00 0x00 0x0000000c  A = instruction_pointer >> 32
 0003: 0x0c 0x00 0x00 0x0000a539  A += X
 0004: 0x54 0x00 0x00 0x00000fff  A &= 0xfff
 0005: 0x15 0x01 0x00 0x00000000  if (A == 0) goto 0007
 0006: 0x06 0x00 0x00 0x00000000  return KILL
 0007: 0x20 0x00 0x00 0x00000000  A = sys_number
 0008: 0x07 0x00 0x00 0x00000000  X = A
 0009: 0x24 0x00 0x00 0x000003e8  A *= 0x3e8
 0010: 0x02 0x00 0x00 0x00000000  mem[0] = A
 0011: 0x87 0x00 0x00 0x00000000  A = X
 0012: 0x24 0x00 0x00 0x000001d7  A *= 0x1d7
 0013: 0x84 0x00 0x00 0x00000000  A = -A
 0014: 0x04 0x00 0x00 0x00031337  A += 0x31337
 0015: 0x07 0x00 0x00 0x00000000  X = A
 0016: 0x60 0x00 0x00 0x00000000  A = mem[0]
 0017: 0x1d 0x01 0x00 0x00000000  if (A == X) goto 0019
 0018: 0x06 0x00 0x00 0x00000000  return KILL
 0019: 0x06 0x00 0x00 0x7fff0000  return ALLOW
    EOS
  end

  it 'else jmp' do
    bpf = [0x15, 0x25, 0x35, 0x45].map { |c| "#{c.chr}\x00\x00\x01\x00\x00\x00\x00" }.join
    expect(described_class.disasm(bpf, arch: :amd64)).to eq(<<-EOS)
 line  CODE  JT   JF      K
=================================
 0000: 0x15 0x00 0x01 0x00000000  if (A != 0) goto 0002
 0001: 0x25 0x00 0x01 0x00000000  if (A <= 0) goto 0003
 0002: 0x35 0x00 0x01 0x00000000  if (A < 0) goto 0004
 0003: 0x45 0x00 0x01 0x00000000  if (!(A & 0)) goto 0005
    EOS
  end

  it 'invalid jmp' do
    expect { described_class.disasm(0x55.chr + "\x00" * 7, arch: :amd64) }.to raise_error(
      ArgumentError, 'Line 0 is invalid: unknown jmp type'
    )
  end
end
