#!/usr/bin/perl
#Rocky 2011-04-12 10:44:35
#
# 功能：使用w3m向爱词霸网发送查词请求，输出简要结果；
# 编写：Rocky 2011-04-12 [rocky2shi@126.com]
#
# history:
#   2011-04-12: v1.0，完成网络查词；
#   2011-04-21: v1.1，1)加入手动输入记录，及查询、删除等项；
#                     2)加入Google翻译；
#   2011-04-22: v1.2.1, 修改read命令；
#   2011-04-25: v1.2.2, 修改--loop中的输入处理；
#   2011-04-27: v1.2.3, 加--edit选项
#   2011-05-02: v1.2.4, 1)修改：单词中含有‘-’时，会输出错误提示；
#                       2)修改默认单词目录；
#   2011-05-04: v1.3, 加入--append选项；
#   2011-05-12: v1.4, 加入--list选项，等；
#   2011-05-26: v1.5, 加入单词读音
#




$COLOR_CYAN  = "\e[36;1m";
$COLOR_QRAY  = "\e[30;1m";
$COLOR_RED   = "\e[31;1m";
$COLOR_NONE  = "\e[0m";
$word_dir = $ENV{DICT_DATA} || "$ENV{HOME}/.dict"; # 优先使用环境变量的值
$mp3_dir = "$word_dir/mp3";
$dict_tmp = "/tmp";
$history = "$word_dir/history.txt";
$tmp_file = "$dict_tmp/.dict_tmp";
$word_str = '';




sub Usage
{
    print <<'eof';

 Usage: dict.pl [word|phrase] [选项]
   word|phrase   : 待查询单词或短语
   --loop        : 查询后不退出
   --history     : 显示查询记录
   --add title   : 手动加入记录，以title为标题；
   --del title   : 删除标题为title的记录；
   --edit title  : 编辑标题为title的记录；
   --append title: 手动添加内容到已存在的词条；
   --list num    : 以查询计数升序列出已有的最后num个词条，默认num=100

编写：[v1.5] [Rocky 2011-05-26] [rocky2shi@126.com]

eof
    exit(1);
}

# 记录查询记录
sub WriteHistory
{
    my $str = $_[0];
    system <<eof;
    echo $str >> $history
    cp $history $tmp_file
    tail $tmp_file -n 100 > $history    # 限制为100行
    rm -f $tmp_file
eof
}

# 取词条文件名（注意，含前缀）
sub GetWordFile
{
    my $word = $_[0];
    my $result = `cd $word_dir  &&  ls [0-9]*.$word -1 2>/dev/null`;
    return split(" ", $result);
}

# 下载读音mp3文件
sub mp3
{
    # 对于多个短语，词间以‘%20’分隔；
    my $word = join("%20", @ARGV) || Usage();
    my $mp3_file = "$word_dir/mp3/@ARGV.mp3";

    # 先查看本地是否已有此读音文件，不存在则下载；
    if(not -f $mp3_file)
    {
        my $cmd = "w3m -no-cookie -dump_source http://www.iciba.com/$word";
        my $text = `$cmd`;

        # 有多个词时，不下载；
        if($text =~ /请尝试查询/)
        {
            return;
        }

        # 取mp3文件url，只取标准读音；
        # asplay('http://res.iciba.com/resource/amp3/0/0/73/1b/731b886d80d2ea138da54d30f43b2005.mp3')
        if($text =~ /'(http:\/\/[^']+.mp3)'/)
        {
            my $url = $1;
            system <<eof;
            (
                wget '$url' -O '$mp3_file' ;
                gst-launch filesrc location="$mp3_file" ! decodebin ! alsasink ;
            ) >/dev/null 2>\&1 \&
eof
            return;
        }
    }

    # 调播放命令
    system <<eof;
    gst-launch filesrc location="$mp3_file" ! decodebin ! alsasink >/dev/null \&
eof
}


# 循环查词（循环调用本脚本）
if($ARGV[0] eq '--loop')
{
    system <<'eof';
    echo "[提示：请在提示符>>>后输入查找词。按Ctrl+C退出。]"
    echo
    while true;
    do
        echo -ne "\e[0m"
        read -p ">>> " -e word;
        [[ "${word}" != "" ]] && dict.pl ${word[*]};
    done
eof
    print "\n";
    exit(0);
}


# 初始化
if(not -d $mp3_dir)
{
    system("mkdir -p $mp3_dir");
}





# 显示查询记录
if($ARGV[0] eq '--history')
{
    system("cat -n $history");
    exit(0);
}

# 手工输入记录信息
if($ARGV[0] eq '--add')
{
    Usage() if($ARGV[1] eq "");
    my @word = @ARGV;
    shift(@word); # 去掉--add
    my $word = join("_", @word);
    my @tmp = GetWordFile($word);
    if(@tmp > 0)
    {
        print "此标题词已存在，请换另一标题，或先删除已存在标题（使用--del选项）。\n";
        exit(1);
    }
    my $word_file = "$word_dir/1.$word";
    print "请输入内容，按Ctrl+D结束输入。\n";
    print "==========================================\n";
    system <<eof;
    echo "**********$COLOR_CYAN @word $COLOR_NONE**********" >$word_file
    echo -e '$COLOR_QRAY' >>$word_file
    cat - >>$word_file
    echo  >>$word_file
eof
    exit(0);
}

# 删除标题词
if($ARGV[0] eq '--del')
{
    Usage() if($ARGV[1] eq "");
    my @tmp = @ARGV;
    shift(@tmp); # 去掉--del
    my $word = join("_", @tmp);
    system <<eof;
    cd $word_dir && rm -f [0-9]*.$word && echo "已删除[@tmp]"
eof
    exit(0);
}

# 编辑标题词
if($ARGV[0] eq '--edit')
{
    Usage() if($ARGV[1] eq "");
    my @tmp = @ARGV;
    shift(@tmp); # 去掉--edit
    my $word = join("_", @tmp);
    system <<eof;
    cd $word_dir && vi [0-9]*.$word
eof
    exit(0);
}


# 手动添加新内容到已存在的词条中
if($ARGV[0] eq '--append')
{
    Usage() if($ARGV[1] eq "");
    my @word = @ARGV;
    shift(@word);
    my $word = join("_", @word);
    my @tmp = GetWordFile($word);
    my $word_file = "$word_dir/@tmp"; # 这里@tmp应只有一个词条
    if(not -f $word_file)
    {
        print "此词条[$word]不已存在（可使用--add选项手动新建）。\n";
        exit(1);
    }
    print "请输入内容，按Ctrl+D结束输入。\n";
    print "==========================================\n";
    system <<eof;
    echo                  >>$word_file
    echo '###手工添加###' >>$word_file
    cat                   >>$word_file
    echo                  >>$word_file
eof
    exit(0);
}

# 列出已有词条
if($ARGV[0] eq '--list')
{
    my $num = $ARGV[1] || 100;
    my $cmd = sprintf<<'eof', $word_dir, $num;
    cd %s || exit 2;
    echo '    序号  计数 词条'
    ls -1 | awk -F. '/^[0-9]+/{printf("%%5s  %%s\n",$1,$2);}' | sort -n | tail -n %d | cat -n
eof
    system($cmd);
    exit(0);
}

# 以-开始的应为命令（不是查询请求）
if($ARGV[0] =~ "^-")
{
    print " $COLOR_RED选项出错：@ARGV\n" . $COLOR_NONE;
    Usage();
}

# 先查看是否已存在查询单词
$word = join("_", @ARGV);
@result = GetWordFile($word);
if(@result > 1)
{
    print "**********$COLOR_CYAN @ARGV $COLOR_NONE**********\n";
    print "$COLOR_QRAY";
    print " 有多个结果，请尝试查询：\n";
    my $word;
    for(my $i; ($word=$result[$i]); $i++)
    {
        $word =~ /([0-9]+).(.+)/;
        print " $2\n";
    }
    print "$COLOR_NONE\n";
    exit(0);
}
$result = "@result";
if($result =~ /([0-9]+).(.+)/)
{
    # 输出已存在的记录，并修改使用计数；
    print "<$1>\n";
    $src_file  = "$word_dir/$1.$2";
    $dest_file = "$word_dir/" . ($1+1) . ".$2";
    system <<eof;
    cat $src_file
    mv $src_file $dest_file
    touch $dest_file
eof
    mp3();
    WriteHistory("@ARGV");
    print "$COLOR_NONE\n";
    exit(0);
}








# 使用http://www.iciba.com翻译
sub iciba
{
    # 对于多个短语，词间以‘%20’分隔；
    my $word = join("%20", @ARGV) || Usage();
    my $cmd = "w3m -no-cookie -dump http://www.iciba.com/$word";
    $text = `$cmd`;
    @lines = split(/[\r\n]/, $text);

    my %word = ();
    my $result = "";
    for($i=0; $i<@lines; $i++)
    {
        my $line = @lines[$i];
        if($line =~ /^过去式：(.*)/)
        {
            $word{'过去式'} = $1;
        }
        elsif($line =~ /^过去分词：(.*)/)
        {
            $word{'过去分词'} = $1;
        }
        elsif($line =~ /^现在分词：(.*)/)
        {
            $word{'现在分词'} = $1;
        }
        elsif($line =~ /^名词复数：(.*)/)
        {
            $word{'名词复数'} = $1;
        }
        elsif($line =~ / 更多资料$/)
        {
            # 结束词头信息
            last;
        }
        elsif($line =~ /([^ ]+) \[英\] \[([^\]]*)\].*\[美\] \[([^\]]*)\]/) # 音标
        {
            # evolve [英] [i?v?lv] [sound] [美] [??v?lv] [sound]
            #$word = $1;
            $word{'英'} = $2;
            $word{'美'} = $3;
        }
        elsif($line =~ /请尝试查询/)
        {
            for(; $i<@lines; $i++)
            {
                my $line = @lines[$i];
                last if($line =~ /相关搜索/); # 退出 退出 退出 退出 退出 退出
                $result .= " $line\n";
            }
        }
    }

    if($result eq "")
    {
        $result =<<eof;
 [英:$word{'英'}] [美:$word{'美'}]
 过去式:[$word{'过去式'}], 过去分词:[$word{'过去分词'}], 现在分词:[$word{'现在分词'}], 名词复数:[$word{'名词复数'}]

eof
        for($i+=2; $i<@lines; $i++)
        {
            my $line = @lines[$i];
            last if(ord($line) > 127);
            next if($line =~ /^$/);
            $result .= " $line\n";
        }

        #$word_str .= "\n\n 以下结果来自互联网：\n";
        #for(; $i<@lines; $i++)
        #{
        #    my $line = @lines[$i];
        #    last if($line =~ /以下结果来自互联网/);
        #}
        #for($i+=2; $i<@lines; $i++)
        #{
        #    my $line = @lines[$i];
        #    last if($line =~ /^$/);
        #    $word_str .= " $line\n";
        #}
    }

    return <<eof;
###爱词霸翻译###
$result
eof
}


# 使用Google翻译
sub google
{   
    # google: http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=test&langpair=en|zh-CN
    #    "responseData": {"translatedText":"测试"}, "responseDetails": null, "responseStatus": 200}
    my $cmd = 'w3m -no-cookie -dump \'http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=' . join("%20", @ARGV) . '&langpair=en|zh-CN\'';
    my $text = `$cmd`;
    $text =~ /\"responseData\": {\"translatedText\":\"([^\"\']+)\"}/;
    return <<eof;
###Google翻译###
 $1
eof
}


my $iciba = iciba();
my $google = google();



$word_str .=<<eof;
**********$COLOR_CYAN @ARGV $COLOR_NONE**********
$COLOR_QRAY
$iciba
$google
eof

if(length($word_str) > 170)
{
    # 显示到前台
    print $word_str;
    $word_file = "$word_dir/1." . join("_", @ARGV);
    # 再写入文件
    open(FILE, ">$word_file") || die "$!: $word_file";
    print FILE $word_str;
    close(FILE);
    mp3();
    WriteHistory("@ARGV");
}
else
{
    print "\n\t未找到: $COLOR_FALSE@ARGV$COLOR_NONE\n\n";
}
