package OpenResty::Handler::Captcha;

use strict;
use warnings;

use utf8;

use Crypt::CBC;
use MIME::Base64;
use Digest::MD5 qw/md5/;
use Encode qw( encode decode is_utf8 );

my $PLAINTEXT_SEP="\001";	# separator character in plaintext str
my $MIN_TIMESPAN=3;			# minimum timespan(sec) for a valid Captcha,
							# verification will fail before this timespan.
							# default to 3s.
my $MAX_TIMESPAN=15*60;		# maximum timespan(sec) for a valid Captcha,
							# Captcha will be invalid after this timespan.
							# default to 15m.

my $Error;
eval "use GD::SecurityImage;";
$Error = $@;

my @CnWordList = qw(
    一本正经 上升 下降 不假思索 专门
    严严实实 严寒 丰收 乌龟 乱成一团
    争奇斗艳 五光十色 交错 人行道 仁爱
    仍然 仙子 代表 仰望 仰起
    价值 传授 传播 似乎 低头
    体贴 使劲 依然 保留 修建
    修理 假装 傲慢 光洁 免得
    全部 关系 兴奋 兴趣 兴高采烈
    冰鞋 冲击力 决心 准备 准确无误
    凉爽 减少 减轻 几乎 凤尾竹
    创举 创造 前夕 前爪 力量
    加紧 动听 勇敢 勇气 包括
    千呼万唤 千奇百怪 卡片 危险 历史
    参加 又松又软 双龙戏珠 古老 可口
    可惜 台阶 各种各样 合二为一 合拢
    同情 名堂 名贵 咱们 品行
    四肢 四脚朝天 回首 固然 图案
    地质学家 坚固 坦克 坪坝 垂头丧气
    大惊失色 大显神威 大概 大腿 大致
    奇怪 奋力 奔流不息 奔跑 好奇
    如实 姿势 威武 娇嫩 嫩绿
    孔雀舞 学问 宇宙 定时 宝贵
    实验 宽裕 密切 密密层层 寻找
    居然 展示 希望 平息 平整
    引人注目 当初 形状 微生物 心意
    忽然 恼怒 悄悄 情况 情绪
    惊讶 愿意 慢吞吞 懂得 懒洋洋
    成功 成果 成群结队 或者 战场
    所以 扇子 手掌 手锯 才干
    打扮 打量 抖动 抢走 披甲
    抽出 担心 招呼 招引 招架
    拜访 拥抱 拼命 持久 按照
    挡住 挤来挤去 捉迷藏 掌声 推动
    推测 提醒 摆弄 摇晃 收藏
    放大镜 敌人 教育家 散步 敬礼
    敬重 文静 斧头 旅行 无论
    昆虫 显微镜 显然 普通话 暗示
    有趣 本能 朴素 杂志社 杏黄
    村子 杨树 果然 柿子 栏板
    检查 植物学家 横跨 欢唱 欢快
    欢蹦乱跳 欣赏 止境 气味 气息
    汇成 油亮亮 沿途 注视 洁白
    浪费 深蓝 清凉 清闲 渔业工人
    游戏 湿度 滋润 激动 炎热
    炮口 热烈 热闹 照相机 爬山
    物产丰富 猜测 献出 玩具 玩意
    玩耍 理会 瓶子 甜蜜 留心
    留意 白发苍苍 盛开 相提并论 相距
    盼望 看守 眼镜 石栏 研究
    确确实实 磨坊 祖祖辈辈 祝福 神气
    秘书 秦岭 穿戴 突然 立刻
    立即 第七课 等候 简单 算术
    粗壮 粮食 精心 精美 紧张
    纪念 纳闷 纸袋 细微 终于
    绒毛 给予 继续 绳子 美观
    考察 肌肤 肥料 肯定 胜利者
    胶卷 胸脯 自卫 自言自语 舌头
    艳丽 节省 芬芳迷人 花瓣 苏醒
    茂密 茂盛 茶杯 荒凉 药材
    获得 菠萝 著名 蝴蝶 血液
    观察 视线 记忆力 记者 讲述
    设计 证明 试探 诚实 请教
    调节 谦虚 超常 路途 躲闪
    转告 转来转去 轮流 辫子 辽阔
    迎候 这些 进攻 远近闻名 迷失
    适宜 适应 遗产 遗迹 遥望
    遥远 邮票 郊外 重量 钓鱼
    铜钟 镜片 长处 长进 阅读
    阻力 陆续 陌生 随便 随意
    难过 雄伟 集合 需要 震惊
    面包渣 顶峰 顺利 颜色 风尘仆仆
    风景优美 飘扬 飘飘摇摇 飞散 飞舞
    首次 香甜 骄傲 高低不平 鲜嫩
    黑暗 鼓励
);

my @WordList = qw(
    about afraid after again against
    agree almost along angry another
    answers arms around away back
    ball basket become begin better
    boat boating books booth born
    both boxes boys bread brush
    burn buses busy cake call
    camping capital care careful carry
    cars catch centre cheaper chess
    china cinema city class clean
    clever coat cold college comb
    come country course cups dark
    days decide declare deed deliver
    develop dinner dirty doctor doing
    door down dress drive each
    early east eight eleven enjoy
    evening every exam excited excuse
    fall family famous fast faster
    father feel fever fifty film
    fine finish first fish fishing
    five floor food foot forty
    four friend friends from front
    full funny future games give
    glad goal good goodbye grade
    ground grow hair half hand
    hands happen hard have head
    healthy hear heavily help here
    high hill history hold hole
    home hour hours house hundred
    hungry hurry hurt idea instead
    into invite jump just keep
    kind kinds knock know ladder
    lake largest last late learn
    leave left lesson lessons letter
    letters life lights like listen
    little live long longer look
    lunch machine make many market
    match matter meals medical meeting
    message middle million minute model
    modern moment money month more
    morning most move much music
    name near nearly need news
    next nice night nine north
    number office once oneself only
    open other over pair papers
    parents parking party pass past
    people piano pick piece place
    plane plant play player plenty
    points post prepare primary promise
    pulling quarter quick quietly race
    rain read ready rest result
    return right road room roses
    round rules rush school scoot
    send seven several ship shirt
    shoes shoot short show shower
    side sides signs singing sixty
    skate skating slim slow slowly
    smile snowman some soon sorry
    south spare speak sports square
    squares stamps stand start station
    stay stop store story street
    student studies study such summer
    supper table take talk tall
    teach teacher team teeth tell
    test thank that them then
    there these thin thing things
    think thirty this three through
    ticket time times today traffic
    train tree trees trip trouble
    turn twenty twice under until
    very view visit voice wait
    wake walk wall want wash
    washing watch ways wear week
    weeks welcome well west what
    when window winter wish with
    word work world worried write
    wrong year your hello moon
);

# Create a normal Captcha ID
sub GET_captcha_column {
    my ($self, $openresty, $bits) = @_;
    my $col = $bits->[1];
    if ($col eq 'id') {
		# Get captcha language param
        my $lang = lc($openresty->{_cgi}->url_param('lang')) || 'en';

        # Generate captcha solution in the language
		my $solution;
		if ($lang eq 'cn') {
			$solution = $self->gen_cn_solution($openresty);
		} elsif ($lang eq 'en') {
			$solution = $self->gen_en_solution($openresty);
		} else {
			die "Unsupported lang (only cn and en allowed): $lang\n";
		}

		if ($OpenResty::Config{"frontend.test_mode"}) {
			# We are in the testing mode
			$MIN_TIMESPAN=1;	# change min valid timespan to 1s
			$MAX_TIMESPAN=3;	# change max valid timespan to 3s
		}

		# Generate min and max valid timestamp
		my $min_valid=time()+$MIN_TIMESPAN;
		my $max_valid=time()+$MAX_TIMESPAN;

        my $id = encrypt_captcha_id($openresty,$lang,$solution,$min_valid,$max_valid);

        return $id;
    } else {
        die "Unknown captcha column: $col\n";
    }
}

sub GET_captcha_value {
    my ($self, $openresty, $bits) = @_;
    my $col = $bits->[1];
    my $value = $bits->[2];

    if ($Error) {
        die "Captchas support not available on this server.\n";
    }

    my $ext = 'gif';
    if ($value =~ s/\.(gif|jpg|png|jpeg)$//g) {
        $ext = $1;
        if ($ext eq 'jpg') { $ext = 'jpeg' }
    }

    if ($col eq 'id') {
        my $id = $value;

		# Decrypt captcha id to get info about the captcha
		my ($rand1,$lang,$solution,$min_valid,$max_valid,$rand2)=decrypt_captcha_id($openresty,$id);

		# Exit if the captcha id is in wrong format
        die "Invalid captcha ID: $id\n" unless defined($solution);

		# Exit if the max valid time of the captcha has expired
		die "Captcha ID has expired: $id\n" if $max_valid<time();

		# Generate image according to captcha info
		if ($lang eq 'cn') {
			$self->gen_cn_image($openresty, $solution);
		} elsif ($lang eq 'en') {
			$self->gen_en_image($openresty, $solution);
		} else {
			die "Unsupported lang (only cn and en allowed): $lang\n";
		}
    } else {
        die "Unknown captcha column: $col\n";
    }
}

sub gen_en_solution {
    my ($self, $openresty) = @_;
    my $str = '';
    my $list = \@WordList;
    my ($i, $j) = (0, 0);
    while ($i < 2) {
        last if $j > 100;
        my $rand = int rand scalar(@$list);
        my $saved_str = $str;
        $str .= $list->[$rand] . " ";
        my $len = length($str);
        if ($len >= 15) {
            $str = $saved_str;
            $j++;
            next;
        }
        $i++;
    }
    $str;
    # XXX debug only
}

sub gen_cn_solution {
    my ($self, $openresty) = @_;
    my $str = '';
    my $list = \@CnWordList;
    my ($i, $j) = (0, 0);
    while ($i < 2) {
        last if $j > 100;
        my $rand = int rand scalar(@$list);
        my $saved_str = $str;
        $str .= $list->[$rand];
        my $len = length($str);
        last if $len == 3;
        if ($len >= 5) {
            $str = $saved_str;
            $j++;
            next;
        }
        $i++;
    }
    $str;
    # XXX debug only
}

sub gen_cn_image {
    my ($self, $openresty, $str) = @_;
    my $angle = int rand 4;
    my $captcha = GD::SecurityImage->new(
        width   => 100,
        height  => 37,
        lines   => 2 + int rand 2,
        font    => "$FindBin::Bin/../font/wqy-zenhei.ttf",
        #thickness => 0.5,
        rndmax => 3,
        angle => $angle,
        ptsize => 15,
        #send_ctobg => 1,
        #scramble => 1,
    );

    #warn $str;
    $captcha->random($str);
    $captcha->create(ttf => 'default');
    die "Failed to load ttf font for GD: $@\n" if $captcha->gdbox_empty;
    $captcha->particle(300); # : 1732);
    my ($image_data, $mime_type) = $captcha->out(compress => 1);
    $openresty->{_bin_data} = $image_data;
    $openresty->{_type} = "image/$mime_type";
    ### $mime_type
}

sub gen_en_image {
    my ($self, $openresty, $str) = @_;
    my $angle = 2 + int rand 4;
    my $captcha = GD::SecurityImage->new(
        width   => 120,
        height  => 30,
        lines   => 1,
        gd_font => 'giant',
        #thickness => 0.5,
        rndmax => 3,
        angle => $angle,
        #ptsize => 80,
        #send_ctobg => 1,
        #scramble => 1,
    );

    #warn $str;
    $captcha->random($str);
    $captcha->create(normal => 'rect');
    $captcha->particle(100); # : 1732);
    my ($image_data, $mime_type) = $captcha->out(compress => 1);
    $openresty->{_bin_data} = $image_data;
    $openresty->{_type} = "image/$mime_type";
    ### $mime_type
}

sub trim_sol {
    my $s = $_[0];
    unless (is_utf8($s)) {
        $s = decode('UTF-8', $s);
    }
    $s =~ s/\W+//g;
    $s;
}

sub validate_captcha
{
	my ($openresty,$id,$word)=@_;
	my ($rand1,$lang,$solution,$min_valid,$max_valid,$rand2)=decrypt_captcha_id($openresty,$id);

	# validate failed if the captcha id is in wrong format
	return (0,"Captcha ID format is incorrect.") unless defined($solution);	# wrong format

	# change true solution for testing purpose
	if($OpenResty::Config{"frontend.test_mode"}) {
		if ($lang eq 'en') {
			$solution = 'hello world ';
		} else {
			$solution = '你好世界';
		}
	}

	# validate failed if the captcha id has expired or not allowed to validate yet
	my $now=time();
	return (0,"Answered too quickly.") if $min_valid>$now;	# ans too early
	return (0,"Captcha ID has expired.")  if $max_valid<$now;	# ans too late

	# Construct cache key for captcha id. We cannot use captcha id directly, for the id itself
	# could be appending any characters without affecting its decryption.
	# Prepending "captcha:" to prevent cache key confliction...
	my $cache_key=join($PLAINTEXT_SEP,"captcha:",$rand1,$lang,$solution,$min_valid,$max_valid,$rand2);
	utf8::encode($cache_key);

	# validate failed if the captcha id has been used
	my $used=$OpenResty::Cache->get($cache_key);
	return (0,"The captcha has been used.") if $used;	# ans used

	# validate failed if user input doesn't match the solution in captcha id
	return (0,"Solution to the captcha is incorrect.") if trim_sol($word) ne trim_sol($solution);	# wrong ans

	# validate succeed, remember which captcha id has been used
	$OpenResty::Cache->set($cache_key=>1,$MAX_TIMESPAN);

	return (1,"Verification succeeded.");
}

sub decrypt_captcha_id
{
	my ($openresty,$id)=@_;
	return () if !defined($id);
	$id=decode_base64_urlsafe($id);
	my ($digest,$cipher)=unpack("a16a*",$id);

	my $secret=get_captcha_secretkey($openresty);
	my $algo=Crypt::CBC->new(
		-key=>$secret,
		-header=>'none',
		-iv=>$secret,
		-cipher=>'Rijndael',
	);

	my $plain=$algo->decrypt($cipher);
	return () unless $digest eq md5($plain);

	my ($rand1,$lang,$solution,$min_valid,$max_valid,$rand2)=split($PLAINTEXT_SEP,$plain);

	return () unless defined($lang) && defined($solution) && defined($min_valid) && defined($max_valid);
	return () unless $min_valid>0 && $max_valid>0;
	return () unless defined($rand1) && $rand1>=0 && $rand1<10000;
	return () unless $rand1==$rand2;

	return ($rand1,$lang,$solution,$min_valid,$max_valid,$rand2);
}

sub encrypt_captcha_id
{
	my ($openresty,$lang,$solution,$min_valid,$max_valid)=@_;
	my $rand=int(rand(10000));
	# Add random number before and after captcha parameters
	# in order to maximum obfuscate the cipher
	my $plain=join($PLAINTEXT_SEP,$rand,$lang,$solution,$min_valid,$max_valid,$rand);

	my $secret=get_captcha_secretkey($openresty);
	my $algo=Crypt::CBC->new(
		-key=>$secret,
		-header=>'none',
		-iv=>$secret,
		-cipher=>'Rijndael',
	);

	my $cipher=$algo->encrypt($plain);

	# Generate a 16-byte MD5 signature for plaintext, to further protect cipher
	utf8::encode($plain);	# XXX: eliminating md5() i/o error
	my $digest=md5($plain);
	return encode_base64_urlsafe($digest.$cipher);
}

sub get_captcha_secretkey
{
	my $openresty=shift;

	# 128 bits secret key for encryption/decryption
	# Prepending "captcha:" to prevent cache key conflication...
	my $key=$OpenResty::Cache->get("captcha:key");
	return $key if defined($key) && length($key)==16;

	# Protect current user for restoring later, we don't want to break the outter context...
	my $cur_user=$openresty->current_user;
	$openresty->set_user("_global");
	my $res=$openresty->select("select captcha_key from _global._general",{use_hash=>1});
	die "Unable to retrieve captcha secret key"
		unless defined($res) && @$res>0 && exists $res->[0]{captcha_key};
	$openresty->set_user($cur_user);

	$key=$res->[0]{captcha_key};
	die "Captcha secret key length invalid, should be exactly 16 bytes"
		unless length($key)==16;

	# Cache the captcha secret key for 1 day
	# Prepending "captcha:" to prevent cache key conflication...
	$OpenResty::Cache->set("captcha:key"=>$key,3600*24);

	return $key;
}

sub encode_base64_urlsafe
{
	# base64 encode the given value and substitute URL-unsafe characters to URL-safe ones
	(my $base64=encode_base64(shift,""))=~y!+/!._!;

	# remove the extra newline appended by encode_base64()
	chomp($base64);

	$base64=~s/=//g;
	return $base64;
}

sub decode_base64_urlsafe
{
	# substitute URL-safe characters to original ones
	(my $base64=shift)=~y!._!+/!;
	my $result;
	{
		# suppress decode_base64() warnings (premature end of data, etc.)
		local $^W=0;
		$result=decode_base64($base64);
	}
	return $result;
}

1;

