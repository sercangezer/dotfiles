# PS1

```bash
export PS1="\[\e[01;33m\]\u\[\e[m\]@\[\e[0;1;92m\]\h\[\e[m\]\[\e[01;35m\][\$(hostname -I | awk '{print \$1}')]\[\e[0m\]:\[\e[01;36m\]\$PWD\[\e[m\] \[\e[01;31m\]\\$>\[\e[m\] "
```

![](images/my-ps1.png)

