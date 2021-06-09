这个分为两部分

# 使用Git减少存储库大小

> https://docs.gitlab.com/ee/user/project/repository/reducing_the_repo_size_using_git.html
>
> 1. 从其开源社区存储库[安装BFG](https://rtyley.github.io/bfg-repo-cleaner/)。
>
> 2. 导航到您的存储库：
>
>    ```
>    cd my_repository/
>    ```
>
> 3. 转到要从中删除大文件的分支：
>
>    ```
>    git checkout master
>    ```
>
> 4. 创建一个提交，从分支中删除大文件（如果它仍然存在）：
>
>    ```
>    git rm path/to/big_file.mpg
>    git commit -m 'Remove unneeded large file'
>    ```
>
> 5. 重写历史记录：
>
>    ```
>    bfg --delete-files path/to/big_file.mpg
>    ```
>
>    对象映射文件将被写入`object-id-map.old-new.txt`。保留它-最后一步需要它！
>
> 6. 强制将更改推送到GitLab：
>
>    ```
>    git push --force-with-lease origin master
>    ```
>
>    如果此步骤失败，`master`则表示您在重写历史记录时更改了分支。您可以还原分支并重新运行BFG以保留其更改，或用于`git push --force`覆盖其更改。
>
> 7. 导航到“ **项目”>“设置”>“存储库”>“存储库清理”**：
>
>    ![存储库设置清理表](https://docs.gitlab.com/ee/user/project/repository/img/repository_cleanup.png)
>
>    上载`object-id-map.old-new.txt`文件，然后按**开始清理**。这将删除所有对旧提交的内部Git引用，并`git gc`针对存储库运行 。完成后，您将收到一封电子邮件。

# 使用Git LFS

> https://docs.gitlab.com/ee/administration/lfs/manage_large_binaries_with_git_lfs.html
>
> 当您需要使用Git LFS将大文件检入Git存储库时，让我们看一下工作流程。例如，如果您要上传非常大的文件并将其检入Git存储库，请执行以下操作：
>
> ```
> git clone git@gitlab.example.com:group/project.git
> git lfs install                       # initialize the Git LFS project
> git lfs track "*.iso"                 # select the file extensions that you want to treat as large files
> ```
>
> 将某个文件扩展名标记为要跟踪为LFS对象后，您可以照常使用Git，而不必重做命令以跟踪具有相同扩展名的文件：
>
> ```
> cp ~/tmp/debian.iso ./                # copy a large file into the current directory
> git add .                             # add the large file to the project
> git commit -am "Added Debian iso"     # commit the file meta data
> git push origin master                # sync the git repo and large file to the GitLab server
> ```
>
> **确保**这`.gitattributes`是Git的跟踪。否则，Git LFS对于克隆项目的人将无法正常工作：
>
> ```
> git add .gitattributes
> ```
>
> 克隆存储库的工作原理与以前相同。Git自动检测LFS跟踪的文件，并通过HTTP克隆它们。如果`git clone` 使用SSH URL 执行该命令，则必须输入GitLab凭据以进行HTTP身份验证。
>
> ```
> git clone git@gitlab.example.com:group/project.git
> ```
>
> 如果您已经克隆了存储库，并且想要获取远程存储库中的最新LFS对象，例如。对于起源的分支：
>
> ```
> git lfs fetch origin master
> ```



## 转换为LFS进行保存（不推荐）

> https://docs.gitlab.com/ee/topics/git/migrate_to_git_lfs/index.html
>
> 考虑一个上游项目示例`git@gitlab.com:gitlab-tests/test-git-lfs-repo-migration.git`。
>
> 1. 备份您的存储库：
>
>    创建您的存储库的副本，以便在出现问题时可以对其进行恢复。
>
> 2. 克隆`--mirror`仓库：
>
>    使用mirror标志进行克隆将创建一个裸存储库。这样可以确保您获得仓库中的所有分支。
>
>    它创建一个名为`.git` （在我们的示例中为`test-git-lfs-repo-migration.git`）的目录，该目录镜像上游项目：
>
>    ```
>    git clone --mirror git@gitlab.com:gitlab-tests/test-git-lfs-repo-migration.git
>    ```
>
> 3. 使用BFG转换Git历史记录：
>
>    ```
>    bfg --convert-to-git-lfs "*.{png,mp4,jpg,gif}" --no-blob-protection test-git-lfs-repo-migration.git
>    ```
>
>    它正在扫描所有历史记录，并查找具有该扩展名的任何文件，然后将它们转换为LFS指针。
>
> 4. 清理存储库：
>
>    ```
>    # cd path/to/mirror/repo:
>    cd test-git-lfs-repo-migration.git
>    # clean up the repo:
>    git reflog expire --expire=now --all && git gc --prune=now --aggressive
>    ```
>
>    您还可以查看如何进一步[清理存储库](https://docs.gitlab.com/ee/user/project/repository/reducing_the_repo_size_using_git.html)，但是对于本指南而言，这不是必需的。
>
> 5. 在镜像存储库中安装Git LFS：
>
>    ```
>    git lfs install
>    ```
>
> 6. [取消保护默认分支](https://docs.gitlab.com/ee/user/project/protected_branches.html)，以便我们可以强制推送重写的存储库：
>
>    1. 导航到项目的**“设置”>“存储库”，**然后展开“ **受保护的分支”**。
>    2. 向下滚动以找到受保护的分支，然后单击“ **取消保护**默认分支”。
>
> 7. 强制推送到GitLab：
>
>    ```
>    git push --force
>    ```
>
> 8. 使用LFS跟踪所需的文件：
>
>    ```
>    # cd path/to/upstream/repo:
>    cd test-git-lfs-repo-migration
>    # You may need to reset your local copy with upstream's `master` after force-pushing from the mirror:
>    git reset --hard origin/master
>    # Track the files with LFS:
>    git lfs track "*.gif" "*.png" "*.jpg" "*.psd" "*.mp4" "img/"
>    ```
>
>    现在，将使用LFS正确跟踪转换后的所有现有文件以及添加的新文件。
>
> 9. [重新保护默认分支](https://docs.gitlab.com/ee/user/project/protected_branches.html)：
>
>    1. 导航到项目的**“设置”>“存储库”，**然后展开“ **受保护的分支”**。
>    2. 从“ **分支”**下拉菜单中选择默认分支，然后设置“ **允许推送”**和“ **允许合并”**规则。
>    3. 点击**保护**。

# 删除历史中过多的LFS文件

https://gitlab.com/gitlab-org/gitlab/-/issues/17711

首先这里有个长期的issue,表明这个是个麻烦的问题.

然后需要更新gitlab,这里是他的这个更新结果:

https://docs.gitlab.com/ee/raketasks/cleanup.html#remove-unreferenced-lfs-files-from-filesystem

嗯,先升级gitlab吧.







# 实际操作

但这里卡在了`git push --force`,上面。。。

卡好久，然后失败可还行。

是不是还需要进一步清理啊。（速度还降到了6kb。。。）

先尝试下进一步清理吧。

所以之前就应该好好搞大文件嘛

烧下两个硬盘吧。一个用来装镜像。。

先把历史里面的python镜像全删了，再考虑git push怎么样？

<!--干，考虑到我现在的网络环境。堪忧啊-->

以及，后面那个2G的大文件我怎么传上去啊

要不，两G的那玩意，分开打包？

卡炸了。

重新clone了次git，这次先进行文件的清理：

> https://docs.gitlab.com/ee/user/project/repository/reducing_the_repo_size_using_git.html

然后再`lfs track`镜像，现在在put。

话说啊，怎么上传速度才几k啊，那得到哪年啊。

使用夏工的电脑就ok了





