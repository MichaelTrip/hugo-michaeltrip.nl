---
title: 'Tips on the CKAD exam'
date: 2021-10-28
draft: false
tags: [kubernetes, Homelab]
---

Intro
-----

So i passed the CKAD exam last september. In this blog i wanted to share some tips.

## Learning matters

For me personally i am the type of guy that learns by just doing it. Set up some Kubernetes node with either
[Kind](https://kind.sigs.k8s.io/) or [Rancher Desktop](https://rancherdesktop.io/) and just try some things out.

Also, check out some great Udemy courses. I personally liked this [CKAD](https://www.udemy.com/course/certified-kubernetes-application-developer/) course by Mumshad Mannambeth.

Also, try some practice exercises from the internet. I just looked some of those up on Github:

* https://github.com/dgkanatsios/CKAD-exercises
* https://github.com/jamesbuckett/ckad-questions

Also, if you have booked the exam, you are also entitled to use the Exam simulator by (killer.sh)[https://killer.sh]. If you log-in on the site of the Linux Foundation there is a link to that exam simulator. You have 2 shots.

## Use autocompletion in your bashrc

When you are working on the CKAD exam, speed is everything. You have approx 15-17 questions to do within one hour, so time is crucial.

You can speed things up by using auto-completion in your shell. To do so, enable auto completion for `kubectl` in your `.bashrc`.

```bash
echo "source <(kubectl completion bash)" >> ~/.bashrc # add autocomplete permanently to your bash shell.
```

After that, you can hit the <tab> button on your keyboard to autocomplete commands. If you are tired of of typing in the whole `kubectl` command you can also alias that command.

```bash
echo "alias k=kubectl" >> ~/.bashrc
echo "complete -F __start_kubectl k" >> ~/.bashrc
```
More information can be found in the [Kubectl cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/), which you can also use on the exam.

## Use bookmarks in your browser

The exam you are about to take is a web-based exam. You are allowed to have one tab open besides your exam tab. This can either be one of the following sites:

* https://kubernetes.io/docs/
* https://github.com/kubernetes/
* https://kubernetes.io/blog/

To make things easier, you are allowed to use bookmarks in your browser. I have created some bookmarks that you can import in your browser. You can find them [here](https://github.com/MichaelTrip/cka-ckad-bookmarks).

## Use kubectl expose

This is a odd one, but i found it very usable. When you create a `pod` or a `deployment` you want it to be served some how. To do this, you can quickly create a `service` for this `pod` or `deployment`.

For example: I have a pod called `nginx`. To create a service for it, i can use `kubectl expose`.

```bash
kubectl expose pod nginx --port=80 --name=servicename
```

Or, if you want a yaml file to edit it and create some more service parameters, use the following command:

```bash
kubectl expose pod nginx --port --name=servicename --dry-run=client -o yaml > service.yml
```

## Use a alias to quickly switch to another namespace

Exam quests will take place in different namespaces and contexts. If there is a question that doesn´t mention a namespace, always use the `default` namespace.

You can switch namespaces by typing this command:

```bash
kubectl config set-context --current --namespace namespacename
```

A bit long, isn´t it? To make life easier i use a alias you can add to your `.bashrc`.

```bash
echo 'alias kn="kubectl config set-context --current --namespace"' >> ~/.bashrc
```

## Create your own .vimrc

If you use vim as your favorite editor, it is important to use the right configuration. You can edit your `.vimrc` in your home folder. I used the following settings:

```
set nu # set numbers
set tabstop=2 shiftwidth=2 expandtab # use 2 spaces instead of tab
set ai # autoindent: when go to new line keep same indentation
set cursorcolumn # You see a column on your cursor so you can easily check the identation.
```

## Some other tips

### Stay hydrated

You are allowed to have a glass or a bottle of water next to you. Mind that this bottle or glass needs to be transparent.

### Clean up your desk before taking the exam

I started the exam 15 minutes before and cleaned up my desk. But, i left my audio speakers on the desk. The proctor asked me to also remove these audio speakers. So please, clean up your desk and remove everything from your desk besides your keyboard, mouse and your laptop.

### Check your questions before you begin

Go through all the questions and begin with the easiest ones first. After that, you have plenty of time to start with the hard questions.

### Check in which context you have to use

At the beginning of every question, it states in which context you will work in. There is also a copy button with to command that you can use. Use this button, it will save you a lot of time.

