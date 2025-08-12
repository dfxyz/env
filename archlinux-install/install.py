#!/usr/bin/python

import os
import subprocess
import yaml

__config = dict()


def sh(cmd: str):
    subprocess.run(cmd, shell=True, check=True)


def loadConfig():
    global __config
    try:
        with open('config.yaml', 'r') as f:
            __config = yaml.safe_load(f)
    except:
        raise Exception('Failed to load `config.yaml`!')


def getOption(key: str, optional: bool = False):
    parts = key.split(".")
    result = __config
    try:
        for part in parts:
            result = result.get(part)
        return result
    except:
        if optional:
            return None
        raise ValueError(f'`{key}` not configured!')


def getIntOption(key: str, optional: bool = False):
    value = getOption(key, optional)
    if not isinstance(value, int):
        raise ValueError(f'`{key}` is not configured as integer!')
    return value


def getStrOption(key: str, optional: bool = False):
    value = getOption(key, optional)
    if not isinstance(value, str):
        raise ValueError(f'`{key}` is not configured as string!')
    return value


def getStrListOption(key: str, optional: bool = False):
    value = getOption(key, optional)
    if not isinstance(value, list):
        raise ValueError(f'`{key}` is not configured as list!')
    for i, item in enumerate(value):
        if not isinstance(item, str):
            raise ValueError(f'`{key}[{i}]` is not configured as string!')
    return value


def getStrDictOption(key: str, optional: bool = False, allowNonStrKey: bool = False, allowNonStrValue: bool = False):
    value = getOption(key, optional)
    if not isinstance(value, dict):
        raise ValueError(f'`{key}` is not configured as dictionary!')
    for k, v in value.items():
        if not allowNonStrKey and not isinstance(k, str):
            raise ValueError(f'`{key}` is not configured as dict[str, str]!')
        if not allowNonStrValue and not isinstance(v, str):
            raise ValueError(f'`{key}` is not configured as dict[str, str]!')
    return value


def getBoolOption(key: str, optional: bool = False):
    value = getOption(key, optional)
    if not isinstance(value, bool):
        raise ValueError(f'`{key}` is not configured as boolean!')
    return value


def writeStringsToFile(path: str, content: list[str]):
    with open(path, 'w') as f:
        for line in content:
            f.write(f'{line}\n')


def installPackages():
    sh('cp mirrorlist /etc/pacman.d/')
    sh('pacman -Syy')
    packages = set()
    with open('packages', 'r') as f:
        for line in f:
            line = line.strip()
            if line.startswith('#'):
                continue
            words = line.split(' ')
            for word in words:
                if word:
                    packages.add(word)
    sh('if [[ -f /mnt/boot/amd-ucode.img ]]; then rm /mnt/boot/amd-ucode.img; fi')
    sh('if [[ -f /mnt/boot/intel-ucode.img ]]; then rm /mnt/boot/intel-ucode.img; fi')
    sh(f'pacstrap -K /mnt {" ".join(packages)}')


def setHostname():
    hostname = getStrOption('hostname')
    sh(f'echo "{hostname}" > /mnt/etc/hostname')


def setTimezone():
    timezone = getStrOption('timezone')
    sh(f'arch-chroot /mnt ln -sf /usr/share/zoneinfo/{timezone} /etc/localtime')


def setLocale():
    locale = getStrOption('locale')
    sh(f'echo "LANG={locale}" > /mnt/etc/locale.conf')
    locales = getStrListOption('locales')
    for locale in locales:
        sh(f"awk -i inplace '/^#{locale}/ {{ sub(\"#\", \"\") }} {{ print }}' /mnt/etc/locale.gen")
    sh('arch-chroot /mnt locale-gen')


def initAccount():
    sh("awk -i inplace '/^# %wheel.*NOPASSWD/ { sub(/^# /, \"\") } { print }' /mnt/etc/sudoers")
    sh("awk -i inplace '/^root:.*bash$/ { sub(/bash$/, \"zsh\") } { print }' /mnt/etc/passwd")
    sh('arch-chroot /mnt passwd --lock root')

    username = getStrOption('defaultAccount.username')
    comment = getStrOption('defaultAccount.comment')
    password = getStrOption('defaultAccount.password')
    extraGroups = getStrOption('defaultAccount.extraGroups')
    sh(f'arch-chroot /mnt useradd -m -c "{comment}" -G "{extraGroups}" -s /usr/bin/zsh {username}')
    sh(f'arch-chroot /mnt sh -c "echo \'{password}\' | passwd --stdin {username}"')

    autoLogin = getBoolOption('defaultAccount.autoLogin', optional=True)
    if autoLogin:
        sh('mkdir -p /mnt/etc/sddm.conf.d')
        writeStringsToFile('/mnt/etc/sddm.conf.d/kde_settings.conf', [
            '[Autologin]',
            'Relogin=false',
            'Session=plasma',
            f'User={username}',
            '',
            '[Theme]',
            'Current=breeze',
        ])


def initFstab():
    content = []
    localOption = getOption('fstab.local')
    if not isinstance(localOption, list):
        raise ValueError('`fstab.local` is not configured as list!')
    for i, item in enumerate(localOption):
        uuid = item.get('uuid')
        if not isinstance(uuid, str):
            raise ValueError(f'`fstab.local[{i}].uuid` is not configured as string!')
        mountPoint = item.get('mountPoint')
        if not isinstance(mountPoint, str):
            raise ValueError(f'`fstab.local[{i}].mountPoint` is not configured as string!')
        fsType = item.get('fsType')
        if not isinstance(fsType, str):
            raise ValueError(f'`fstab.local[{i}].fsType` is not configured as string!')
        options = item.get('options')
        if not isinstance(options, str):
            raise ValueError(f'`fstab.local[{i}].options` is not configured as string!')
        dump = item.get('dump')
        if not isinstance(dump, int):
            raise ValueError(f'`fstab.local[{i}].dump` is not configured as integer!')
        passNum = item.get('pass')
        if not isinstance(passNum, int):
            raise ValueError(f'`fstab.local[{i}].pass` is not configured as integer!')
        content.append(f'UUID={uuid} {mountPoint} {fsType} {options} {dump} {passNum}')
    remoteOption = getOption('fstab.remote', optional=True)
    if remoteOption:
        ip = getStrOption('fstab.remote.ip')
        username = getStrOption('fstab.remote.username')
        password = getStrOption('fstab.remote.password')
        mountRoot = getStrOption('fstab.remote.mountRoot')
        options = getStrOption('fstab.remote.options') + f',credentials={mountRoot}/.credentials'
        dirs = getStrListOption('fstab.remote.dirs')
        if dirs:
            sh(f'mkdir -p /mnt{mountRoot}')
            writeStringsToFile(f'/mnt{mountRoot}/.credentials', [
                f'username={username}',
                f'password={password}',
            ])
            sh(f'chmod 600 /mnt{mountRoot}/.credentials')
            for i, dir in enumerate(dirs):
                sh(f'mkdir -p /mnt{mountRoot}/{dir}')
                content.append(f'//{ip}/{dir} {mountRoot}/{dir} cifs {options} 0 0')
    writeStringsToFile('/mnt/etc/fstab', content)


def setFontPreferences():
    fontPreferences = getStrDictOption('fontPreferences', optional=True, allowNonStrValue=True)
    if not fontPreferences:
        return
    content = [
        '<?xml version="1.0"?>',
        '<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">',
        '<fontconfig>',
    ]
    for family, value in fontPreferences.items():
        if isinstance(value, str):
            value = [value]
        if not isinstance(value, list):
            raise ValueError(f'`fontPreferences.{family}` is not configured as string or list of strings!')
        for i, item in enumerate(value):
            if not isinstance(item, str):
                raise ValueError(f'`fontPreferences.{family}[{i}]` is not configured as string!')
        content.extend([
            f'  <match>',
            f'    <test name="family"><string>{family}</string></test>',
            f'    <edit name="family" mode="prepend" binding="strong">',
        ])
        for item in value:
            content.append(f'      <string>{item}</string>')
        content.extend([
            f'    </edit>',
            f'  </match>',
        ])
    content.append('</fontconfig>')
    writeStringsToFile('/mnt/etc/fonts/local.conf', content)


def enableServices():
    services = getStrListOption('enableServices', optional=True)
    if not services:
        return
    for service in services:
        sh(f'arch-chroot /mnt systemctl enable {service}')


def createEfiBootStub():
    enable = getBoolOption('createEfiBootStub.enable', optional=True)
    if not enable:
        return
    label = getStrOption('createEfiBootStub.label')
    disk = getStrOption('createEfiBootStub.disk')
    part = getIntOption('createEfiBootStub.part')
    loader = getStrOption('createEfiBootStub.loader')
    extraArgs = getStrListOption('createEfiBootStub.extraArgs')
    sh(f'efibootmgr -c -L "{label}" -d {disk} -p {part} -l "{loader}" -u "{" ".join(extraArgs)}"')


def clearRootDir():
    sh('rm -rf /mnt/root/.*')


def main():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    loadConfig()
    installPackages()
    setHostname()
    setTimezone()
    setLocale()
    initAccount()
    initFstab()
    setFontPreferences()
    enableServices()
    createEfiBootStub()
    clearRootDir()

if __name__ == '__main__':
    main()
