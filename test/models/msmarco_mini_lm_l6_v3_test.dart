import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fonnx/models/msmarcoMiniLmL6V3/msmarco_mini_lm_l6_v3.dart';
import 'package:fonnx/models/msmarcoMiniLmL6V3/msmarco_mini_lm_l6_v3_native.dart';
import 'package:ml_linalg/linalg.dart';

extension Similarity on Vector {
  double similarity(Vector vector) {
    final distance = distanceTo(vector, distance: Distance.cosine);
    return 1.0 - distance;
  }
}

void main() {
  const modelPath =
      'example/assets/models/msmarcoMiniLmL6V3/msmarcoMiniLmL6V3.onnx';
  final miniLm = MsmarcoMiniLmL6V3Native(modelPath);

  Future<Vector> vec(String text) async {
    return (await miniLm.embed(text)).first.embedding;
  }

  test('Embedding works', () async {
    final answer = await vec('');
    expect(answer, hasLength(384));
  });

  test('Normalize works', () async {
    final result = await miniLm.truncateAndGetEmbeddingForString('');
    expect(result.embedding, hasLength(384));
  });

  test('Performance test', () async {
    final List<String> randomStrings =
        MsmarcoMiniLmL6V3.tokenizer.tokenize(data).map((e) => e.text).toList();
    const count = 100;
    List<Future> futures = [];
    final sw = Stopwatch()..start();
    for (var i = 0; i < count; i++) {
      final future = miniLm.embed(randomStrings[i % randomStrings.length]);
      futures.add(future);
    }
    await Future.wait(futures);
    sw.stop();
    final elapsed = sw.elapsedMilliseconds;
    debugPrint(
        'Elapsed: $elapsed ms for $count embeddings (${elapsed / count} ms per embedding)');
  });

  test('Similarity', () async {
    final result1 = await miniLm.truncateAndGetEmbeddingForString('Bonjour');
    final result2 = await miniLm.truncateAndGetEmbeddingForString('Ni hao');
    final result = result1.embedding.similarity(result2.embedding);
    expect(result, closeTo(0.166, 0.001));
  });

  test('Similarity: weather', () async {
    final vRandom = await vec(
        'jabberwocky awaits: lets not be late lest the lillies bloom in the garden of eden');
    final vSF = await vec('shipping forecast');
    final vAnswer =
        await vec('WeatherChannel Spain the weather is sunny and warm');
    final vWF = await vec('weather forecast');
    final vSpainWF = await vec('spain weather forecast');
    final vWFInSpain = await vec('weather forecast in Spain');
    final vBuffaloWeatherForecast = await vec('buffalo weather forecast');

    final sRandomToAnswer = vRandom.similarity(vAnswer);
    final sSFToAnswer = vSF.similarity(vAnswer);
    final sWFToAnswer = vWF.similarity(vAnswer);
    final sSpainWFToAnswer = vSpainWF.similarity(vAnswer);
    final sWFInSpainToAnswer = vWFInSpain.similarity(vAnswer);
    final sWFInBuffaloToAnswer = vBuffaloWeatherForecast.similarity(vAnswer);

    expect(sRandomToAnswer, closeTo(0.054, 0.001));
    expect(sSFToAnswer, closeTo(0.313, 0.001));
    expect(sWFInBuffaloToAnswer, closeTo(0.344, 0.001));
    expect(sWFToAnswer, closeTo(0.493, 0.001));
    expect(sSpainWFToAnswer, closeTo(0.778, 0.001));
    expect(sWFInSpainToAnswer, closeTo(0.787, 0.001));
  });

  test('Similarity: password', () async {
    final vQuery = await vec('whats my jewelry pin');
    final vAnswer = await vec('My safe passcode is 1234');
    expect(vQuery.similarity(vAnswer), closeTo(0.234, 0.001));
    final vRandom = await vec('Rain in Spain falls mainly on the plain');
    expect(vQuery.similarity(vRandom), closeTo(0.017, 0.001));
  });

  test('Similarity: London', () async {
    final vQuery = await vec('How big is London');
    final vAnswer =
        await vec('UK capital has 9,787,426 inhabitants at the 2011 census');
    expect(vQuery.similarity(vAnswer), closeTo(0.347, 0.001));
  });
}

const data = '''
Lorem Ipsum es simplemente el texto de relleno de las imprentas y archivos de texto. Lorem Ipsum ha sido el texto de relleno estándar de las industrias desde el año 1500, cuando un impresor (N. del T. persona que se dedica a la imprenta) desconocido usó una galería de textos y los mezcló de tal manera que logró hacer un libro de textos especimen. No sólo sobrevivió 500 años, sino que tambien ingresó como texto de relleno en documentos electrónicos, quedando esencialmente igual al original. Fue popularizado en los 60s con la creación de las hojas "Letraset", las cuales contenian pasajes de Lorem Ipsum, y más recientemente con software de autoedición, como por ejemplo Aldus PageMaker, el cual incluye versiones de Lorem Ipsum.

Lorem ipsum dolor sit amet, adhuc euripidis cu vim. Nullam assentior mediocritatem vim at. Ius no sint tacimates, agam omnes cu quo. An sed dolore salutatus delicatissimi, dicant legimus at cum. Exerci offendit interpretaris ius cu, et sea graeco voluptaria. Id tantas erroribus reprehendunt mei.

Qui an dicit libris, reque accusamus iracundia no nec, dicant soluta option eu qui. Sit novum vidisse sapientem eu, duis euripidis mea at, et usu audiam lucilius. Facilis senserit rationibus eu has, oportere dignissim ex duo. Nonumes sadipscing contentiones ad nam.

Ex his everti sadipscing, erat inani duo no. Ius mollis repudiare forensibus eu, has natum omnis reque ex, labores mandamus intellegebat no vis. Commune forensibus voluptaria usu cu, tation consulatu honestatis ut duo. Tantas dignissim vulputate pro ei.

Decore putent cotidieque ne pri, fuisset pertinacia vel ei. Adhuc officiis nam te, mei noluisse interesset an, atomorum antiopam ex sit. Mei probo scripserit efficiantur ut. Te usu possim accusamus torquatos, mea ea viris animal salutatus, ad mei dolore alienum.

Cum legere platonem et. Ea simul delectus vix, cu dico vidit exerci pri. Quo ex nisl choro. Mea audiam persius fastidii ad, est ad quot aeque viderer. At eruditi placerat antiopam vim. Ut duo vidisse accommodare.

Aufgemerkt! Das halsstarrig Muckefuck. Die hochgestochen Jungfer. Das Kaiserwetter picheln der halbstark Blockwart. Gamaschen und Rostbratwurst krakelen hochgestochen Sittenstrolch. Die ausgemergelt Sättigungsbeilage. Weinbrandbohne und Sülze ergötzen ausgemergelt Rädelsführer. Übeltäter und Gamaschen ergötzen hochnäsig Übeltäter. Die kess Schelm. Der Fräulein betören der halbstark Kinkerlitzchen. Das stramm Quasselstrippe anschwärzen. Die hold Bagage stagnieren. Jungfer und Blutwurst ergötzen einfältig Thusnelda. Der halsstarrig Weinbrandbohne. Lecko mio!

Лорем ипсум долор сит амет, вел алиенум рецусабо цонвенире ад. Иудицо вереар хас цу. Про пробо регионе демоцритум ид, еу натум харум дицерет яуи, еиус цомпрехенсам ин вих. Дицам оптион ид усу, ассум пертинациа еам не. Еум ид нобис дицант, еос не цонгуе еяуидем, ин видит нулла мел.

Вих ет бонорум минимум, утрояуе епицури еа усу, усу цу оратио еуисмод. Елитр адверсариум вих ех, еа хис латине тинцидунт, атяуи ассум долорум еа еос. Пурто адхуц иус ин. Еу латине репримияуе сеа, фабулас цонсулату реформиданс еи ест, при ан ностро апеириан елецтрам. Меа епицури нецесситатибус ин, импетус посидониум вис ех.

Ерос санцтус еи мел, еам стет цаусае детрахит ат, хис еа платонем репрехендунт. Постулант демоцритум инструцтиор вис ан. Пурто санцтус долорем вел те, яуи алии фабулас ан. Хабемус еффициенди сигниферумяуе ех цум, омиттантур детерруиссет ан нец, дуо пурто иудицо еа. Нец толлит вениам еу, хас но сапиентем сплендиде. Но нихил моллис усу, еа бруте волуптариа яуи, ат веро хомеро видиссе ест. Сед алияуид апеириан ан, еа дуо тациматес адверсариум.

Ид мел инани омиттантур, лаореет сцаевола инцоррупте яуо ат. Еяуидем лаборес цу еум. Вих дебет инструцтиор не, фуиссет инимицус сенсерит ан хас. Ад хас иллуд цонгуе мелиус, ипсум цорпора цонсецтетуер не вис, еа хас риденс делецтус.

Хис ад миним еверти еррорибус. Еос десеруиссе нецесситатибус еа. Еи веро доценди усу, омнис дицам репрехендунт ид ест. Алияуам медиоцрем меи но, малорум цопиосае ан меи.

Вих тота игнота ет, усу натум сцрипта но. Сед еррор инвенире еу, еи граецо мелиоре дефинитионес хас. Те нец аеяуе доценди, еа вим яуем апеириан. Лаборес фуиссет но меа. Яуи фабулас ратионибус не.

Не сед детрацто нолуиссе цонституто. Ех нумяуам волутпат сплендиде сит, ад лаудем плацерат волуптатум меи, те вих аутем анциллае опортере. Магна модератиус нецесситатибус не хас. Ин еам темпор яуаестио, еам ин дицо перицулис темпорибус. Мел малуиссет дефинитионес ут, пер ан инимицус демоцритум, ех легере номинати яуо. Ин еос витае яуандо видерер, ин нец мовет цонсецтетуер.

Еи вим воцент репудиандае, еос те симул лаборе салутанди. Еррем интеллегам цу еам. Ид порро адолесценс реферрентур меи, диам демоцритум цонцлудатуряуе ут нам, ад алии мовет губергрен нам. Иус ан малуиссет волуптариа диспутандо, ин диам аудире бонорум еос. Не нострум перпетуа репудиандае хис, ест аццусата лаборамус персеяуерис еа. Еам алтерум инермис рецусабо ид, ех солум нолуиссе детрахит нам, ан ментитум хонестатис цотидиеяуе про.

Ет пробо пробатус вел. Цонсул ментитум ан меа, либер ментитум еам ут, меа поссим фацилисис ин. Ан персиус орнатус лаборамус мел, юсто хомеро еа еам. Пер ет мелиус трацтатос персеяуерис, вел ан проприае импердиет. Хас еа миним утамур цонвенире, мунере десеруиссе те нам, доминг иуварет но вим. Ад усу долорум салутанди, иус прима лаореет ан.

Но усу сенсерит ассентиор мнесарчум, ат вис елецтрам интеллегам. Меа дебет лаборе неглегентур ид, лудус нецесситатибус хис ан. Ет мелиус еуисмод нонумес яуи, ат меи суммо адолесценс, про аперири адмодум ех. Лорем антиопам цу.

軽引女値就日福論止外記済示革旋山当止徴新。衛府朝援神酒者銀票小各連慶的。用一含盗敗断庭懲展初告難張中宅破盗。夕重介変禎緻科騰走愛問関。造術統覧読出裁図需案議情機自径。地児視済自防格室変府田鈴援。全勝室想演人安能護六材際禎府日根。経今転記被康更介覧街割坊雪。理財後中器権社稿禁絡川断市政法芸岸龍姿最。

者購真提表柳百他手設牧文。前報情質薬資年間性送確合同局。象出広版投護会正測奥広観持。社味齢谷検棋客大安位悪歳私女求助室成。紀但野菜面他来之五闘一参気画代負囲。本取者聞彼目切朝著全材再意週雲覧感門提。碁漫巳面体択院給衝態国任平球念前調家。入投資気辞銀転薄使両全属禁際簡卓車禁。必督来五真器謙浸鈴寝子活止芸介校。

図込場再度賛国光売認任本兆圧。点位爆木最必肩択思九厚整反。土大別会輸特蔵権位椅者果発題東記米社供。捕占挙阪所与葉希速害崎巻。内毎出末埼催馬待清敏口得法月田必報処止掲。図天止田響核栄拡戸景優負政利全特壊博賀。来傷問級思国雪読雅味豊切場住行収創。属第必歩無段度気火生堀駅予件極幼。問身細連第翼牛通語文将能靖州第編幸十掲。

質系終利合国工過都悦問特石制品。升外徹能五市免由斉葬企映人進成本族庭。走機表写米事氏毎変断多先平明。感無必京事発飛賞空藤禁検。崎材稿築広間因株介改掲放線惑間撤将入。国突団日独応世幌発海目無付責回返駐。意面予容消落管心命案作油。人昭止勝世速航表供憲市挙時一民足。思数業告塊月切非格合投右務文解著静撃。

税速誕下舞本用下提体日社茨記先。日雪凝認宮質変帰交待碁提臣止位。活創状日数専芸戸線撤覧菅作山幕。隠組請米視浦格用連地感去票催能照疑果。紙再郎替法任上管調率族自局聴回文視大載。電塚賛講飼哉更囲回敬火山決新注。全変屋経長波社球不行険先別働戒変。利直馬発月点支気凍教本記。覧国姿戦奏続徴南振生相止天作馬引自理。

教戦味東航経罪転代書下中面事。京権険定陽体題願変借朝芳情。権供図給落販更枯宿西国意止必。軟遺県苦社格地象強何供議壊。際轢因女中作清野聞都闘評済持森用。無散水有宅戸体神香棋展質着界東球。団権月判憂前約古名世調町元取際惜住梨毎説。強講車院百十英苦視前担教秀田際権条。験競分土手水暮取案管文覧策。迎令多展聞稿賞南雄報産繰破川。

払坊枝載断歩棋身自司系破月捨芸。高保込区間減同者室落一持責。取責的経南定前皆交優公柔長定象。沢欠勝挙闇消来済辺満県員意人兼棋円。利能南学作率免柴山増将暮真。日共年難指協速変司存紙関口異立八旨。高南環音表体表審食転目求学賞考己顔。料読連亮池配症懐劇需笑大新態大疑周雑表波。記業季洗爆戸活制図必日事経外直前思。

運生閉科成調準際葉優邦服転責変。例新引芸株場念定利応量方康話橋。医作温無三王軽際提索載最札。気記上最解申坊豊統午笠選。賃貢態転改月教安試校帯了載毎音属面活。転掲売領会害自由氏授正人前電。提暮森位出幸後提細歩速円傑路入周。書典爆短横通要叙発主配試売財。点外使年呼効棋検島青立賞郵営。政達直営死井護資経相前例産更県薄断化目。

海毎影話相約現掛朝態月者日応馬販覧。養想文水向惑富命作後知触展臓乗果。再温名方垂選点反挙政座航。無紹動碁校若肉禁度交分何交日店得専。窄補日問約殻員逮禁弱大三。経滋受身年身方江伝熊約止遂日断保始析選光。東委月夏書政割無報受部和名不生述刊神給川。見広百近放健刷兵権初紀日。政投記役総後反県資未馬力質俑戦回貿。

意名当未善相削月給釈文生独受忍。暮隊離税退例済速打任歌転週輸健狙受市図存。義印題欲夢切市重側見復主掲衆告狙更未事。広極関活半察中文討真半目趣主邦合戦。立販利認懲日針人問把更時暴予。決康育日相由待明大省瞬法投。回投稿属申異座達売市読滋数後。中響謙夜育全字康提野野条活事報景釈病。禁右日私装金州弾封理条滞般基作問改公文創。

速期ヨ映5意児ぴ治9面トテホ記西セヌロ理続づりどべ福面ネウチカ強戦ヱク味読つ社首助ほ般街高ンのぴよ一報えね長合がスみ喜仰す。見ウケキ持今ぴりトく載掲ツウ撤直暮ぼべ武8発作まよぴふ紙著え堂掲ヲリオ別閣ロレマ優当12男た。人せいぜじ経機クメハ約読ヌワリツ四利ちださぐ未市クルホ間役年ルみ権統学にゅ要戦やて去合オテ脱後ハ点断んほょの革京ふー強小ヨウア体幹色なや。

座提ニケメユ使載ニホス発国ウツヨ癒鶴カユア望室ふ頭通ぴみ込翌通大けそび課周子うら体垣クめト体月オムマヲ道目伴飯駆先が。速ゅは分面ぼぶやフ時指島ゅりび旬康だよ載4同げレクみ宮1事出ず月装ホナ子天あよ月田ほおむ最5省ノヒ告跡域施会めなん。駒ムヘソ以面月フケア辞文ーぼ同証く地済ゆ山人ケ健成ルレシミ朝木ア点長ヱレ形市ノヲシ慎52害阪拍フ。

8知上ラムホ多漏とろ接標ユヲ広面ナテニ時建レセヱ止夕時目ヱテア存進ばにびて感文ほドず副教ヌニス出転ろリそ早分リなぎ況契絡何亜き。療へぜみ及地ノモアツ集米レエ世例ヘムルフ盗写みスつ芝摂優ラびむ引躍ンはリも記法ア報士経づイくす小暮とん見4覚四登ゆほ。被崎クテ供注抱でへトン探協ムオケ争56作くルだ成回じはルぜ国権お憲首ゅしドひ勝著ネ引36長かせく経米さひは教他ラ提独季ヤソレオ物橋値敷全リ。

徴けの給30容ス請衣ルゅ情緒サ投高車ミケ総文むろりう君球ノ然師ムメウス名監ヲサセ示95据灯琴75利じぜす。循モソヤ供国チク逃村ミヒ展取ゆ海止メ献表月ぴ臨健上ツナネタ構口ホシモク内日しつる持視でドわべ憂済アクナ川覧ホセラ知地イモメタ前再だゅゃ無別得ぐ皇番よどけ指輪乃隔略たぶに。環べ川人故いドべづ鮮必供めで自抵写いーたえ応天よ充氷づ度考金ルテアキ商持フめクぱ国4会のじく。

日せ覧池ぼゅー力門含ーぞフッ録属にめの吹真画ルムサ現画やか死細ぐぼ来日しレクり申特あクむ児庫ばりじ人都ムアヌネ終局スシク隆雪リ価載モ握鉄誰ば。壊びリ部9拉切ウ関冬シ妻縮ム心8必カイチネ分室さびーか佐下きっん発表ながちん発神テヲマム分5覚まてたみ。写ホラ宮2需落復人顔こだれ覚覧サニコチ件天合惑カハイノ種争ゃあね昇福ユ豆中ウ博見ヌ跡径わつぎひ家70連すフッ挙並怠殊いむたえ。

体スざ智発ヘヌテム際起アモ線際ず政載ワシヱ最感ば見作向をそ害重じ神室ぞぽゅ京無アオタウ海分ヱ広死末張棋じひぴ。茶イ出割ワレカ器味ルメマム理24高さッ発先ウメイソ降森りせでぽ側河ヤ道禁けンなば党日りドぽ数供ニワラア禁5下社芸ぶあ花85工必クえのう婦追門君恵が。下ぶけるぱ選表ヲテ無92柳現す事車らちめ掲求っに開敬陽くちす基開ヌ効何ゆひびぐ透賢ムソレ属江陸聞ヌモ南公抄ざかるイ。

7他ッず宏浜ヨオウフ画績ルえ社結リ小収強びリゅ自作ノラキコ肌緊マ買4信へほだ破2女そぶどば一中に労構満番ーがこへ。社さよみむ会告ぶびりね頭千ツ連海れじ付勝事交オニ重政スシトケ図静リ取後ぼほだざ五級トキフミ芸面交ムコタケ小財エタ真3提経ょに琲話はじらげ千盟では査7勇占祉努おうはれ。読メニヌ算界ヱセ格誉先も交業アミケス文小ムクコヌ場斉ヱコケ県載え通聞掲山がじ悪人テミ載磨範だたづば。

建あすふ信意っ紙全れま階億日ぐばせお新非ヤヒ神1天実リソト結的チミケ済陽転抽綱却欠ぼのみ。長かづべ任疑ンおぜ無一ふどうへ高予ンさぜわ中之サ頭37彦モハレロ直捕ハ売回ゆば再自メ会客のもリだ井記オキ弱査提ケシエ試動やゅ請奇拝括樫みだ。文ろぶぎ長表新キテラヘ設堀ミ実県ヱオソ師世図ゅク読東めむラ面書ホヲ設7論あ展円ラ図3員っ防投トヨ貨禁学ワケ標都えぽ宮冷勧ぎょ。

武絞ぽふび門岳るひド争団でへめん期毒ヲ名治さうせゅ評望ん接安ウイ象7相なけ述8売かめゅド真3異東ぼばく少偽ネコタ持行砂ど更景オソ最元みふっ。口止ス狂暮禁ウク込1洋ヤ度題マスネテ縄早どレク舞被オ神公っ政紆ロニテ社持はべぽ面全南っどあ掲志争効ルみトづ。都テ以購ーどんフ唆直ば活設ラ解素ヲハチナ特変ヤソフチ判場がらしひ業背浅ト著文ろ空済校再ヨ率丘甘こフぴふ。

降マナム断会ケニロ給屋づゅ都対ッ見材むでつを家載利ゆ末容料ニワ注償散ヒヨロ掲錯もゃせだ胸丁トソヱ念半有探前ば。園作カラケ者20奥便岐盟4着ドば氾処メフルト写断いへほせ申言に提稿えめいよ病化著タコ提5害のぐ。彰過ヘルヨヌ青指みざろ材90高まだトえ判女リヲヤケ会写はしぴま戸定ヘヒ外決ナソ分作てけばが見案ゃるほ進31説へむべ社意へ話者レマ審配ヘ含権こ呼立語こえ。

食う寝る処に住む処、グーリンダイのポンポコピーのポンポコナーの。シューリンガンのグーリンダイ。寿限無、寿限無、やぶら小路の藪柑子、水行末 雲来末 風来末。食う寝る処に住む処、長久命の長助、水行末 雲来末 風来末。

食う寝る処に住む処。寿限無、寿限無。水行末 雲来末 風来末。五劫の擦り切れ、シューリンガンのグーリンダイ。寿限無、寿限無。シューリンガンのグーリンダイ。水行末 雲来末 風来末。海砂利水魚の、パイポパイポ パイポのシューリンガン。やぶら小路の藪柑子、パイポパイポ パイポのシューリンガン。食う寝る処に住む処。グーリンダイのポンポコピーのポンポコナーの。

海砂利水魚の。五劫の擦り切れ。長久命の長助、水行末 雲来末 風来末。長久命の長助、パイポパイポ パイポのシューリンガン、食う寝る処に住む処。寿限無、寿限無。パイポパイポ パイポのシューリンガン、やぶら小路の藪柑子、食う寝る処に住む処。グーリンダイのポンポコピーのポンポコナーの、水行末 雲来末 風来末。寿限無、寿限無。シューリンガンのグーリンダイ、シューリンガンのグーリンダイ。グーリンダイのポンポコピーのポンポコナーの。やぶら小路の藪柑子、海砂利水魚の。

食う寝る処に住む処、やぶら小路の藪柑子、寿限無、寿限無。寿限無、寿限無。水行末 雲来末 風来末。シューリンガンのグーリンダイ、シューリンガンのグーリンダイ、海砂利水魚の。水行末 雲来末 風来末。パイポパイポ パイポのシューリンガン、やぶら小路の藪柑子、五劫の擦り切れ、長久命の長助。

海砂利水魚の。グーリンダイのポンポコピーのポンポコナーの。寿限無、寿限無、五劫の擦り切れ、五劫の擦り切れ、やぶら小路の藪柑子、食う寝る処に住む処。グーリンダイのポンポコピーのポンポコナーの、シューリンガンのグーリンダイ。食う寝る処に住む処。やぶら小路の藪柑子。パイポパイポ パイポのシューリンガン、海砂利水魚の。パイポパイポ パイポのシューリンガン。シューリンガンのグーリンダイ。長久命の長助、水行末 雲来末 風来末。寿限無、寿限無。水行末 雲来末 風来末。

食う寝る処に住む処。食う寝る処に住む処。海砂利水魚の。グーリンダイのポンポコピーのポンポコナーの。寿限無、寿限無、シューリンガンのグーリンダイ。パイポパイポ パイポのシューリンガン。五劫の擦り切れ。寿限無、寿限無。水行末 雲来末 風来末、やぶら小路の藪柑子。海砂利水魚の、五劫の擦り切れ、水行末 雲来末 風来末、パイポパイポ パイポのシューリンガン、シューリンガンのグーリンダイ。

シューリンガンのグーリンダイ、寿限無、寿限無、水行末 雲来末 風来末、食う寝る処に住む処。長久命の長助。長久命の長助、パイポパイポ パイポのシューリンガン、やぶら小路の藪柑子、食う寝る処に住む処、五劫の擦り切れ、海砂利水魚の。グーリンダイのポンポコピーのポンポコナーの、グーリンダイのポンポコピーのポンポコナーの。やぶら小路の藪柑子、水行末 雲来末 風来末。寿限無、寿限無。海砂利水魚の。シューリンガンのグーリンダイ。五劫の擦り切れ、パイポパイポ パイポのシューリンガン。

五劫の擦り切れ。寿限無、寿限無。寿限無、寿限無、長久命の長助、食う寝る処に住む処、やぶら小路の藪柑子、シューリンガンのグーリンダイ。シューリンガンのグーリンダイ、食う寝る処に住む処。

パイポパイポ パイポのシューリンガン、パイポパイポ パイポのシューリンガン。長久命の長助。水行末 雲来末 風来末。食う寝る処に住む処、五劫の擦り切れ。海砂利水魚の。長久命の長助、やぶら小路の藪柑子。グーリンダイのポンポコピーのポンポコナーの、食う寝る処に住む処、寿限無、寿限無。海砂利水魚の。シューリンガンのグーリンダイ。寿限無、寿限無。

グーリンダイのポンポコピーのポンポコナーの。寿限無、寿限無。水行末 雲来末 風来末、やぶら小路の藪柑子、シューリンガンのグーリンダイ。食う寝る処に住む処。やぶら小路の藪柑子、長久命の長助、寿限無、寿限無。グーリンダイのポンポコピーのポンポコナーの、パイポパイポ パイポのシューリンガン、五劫の擦り切れ。

헌법재판소 재판관은 탄핵 또는 금고 이상의 형의 선고에 의하지 아니하고는 파면되지 아니한다, 감사원은 원장을 포함한 5인 이상 11인 이하의 감사위원으로 구성한다. 정당의 설립은 자유이며. 대통령은 국가의 독립·영토의 보전·국가의 계속성과 헌법을 수호할 책무를 진다.

대법관은 대법원장의 제청으로 국회의 동의를 얻어 대통령이 임명한다. 국가는 과학기술의 혁신과 정보 및 인력의 개발을 통하여 국민경제의 발전에 노력하여야 한다. 대한민국의 국민이 되는 요건은 법률로 정한다. 국가원로자문회의의 조직·직무범위 기타 필요한 사항은 법률로 정한다.

행정각부의 장은 국무위원 중에서 국무총리의 제청으로 대통령이 임명한다. 제3항의 승인을 얻지 못한 때에는 그 처분 또는 명령은 그때부터 효력을 상실한다, 누구든지 체포 또는 구속을 당한 때에는 즉시 변호인의 조력을 받을 권리를 가진다. 이 헌법공포 당시의 국회의원의 임기는 제1항에 의한 국회의 최초의 집회일 전일까지로 한다.

국회는 국무총리 또는 국무위원의 해임을 대통령에게 건의할 수 있다. 국토와 자원은 국가의 보호를 받으며. 국회의원은 법률이 정하는 직을 겸할 수 없다. 법률이 정하는 주요방위산업체에 종사하는 근로자의 단체행동권은 법률이 정하는 바에 의하여 이를 제한하거나 인정하지 아니할 수 있다.

탄핵의 결정. 대통령이 제1항의 기간내에 공포나 재의의 요구를 하지 아니한 때에도 그 법률안은 법률로서 확정된다, 모든 국민은 법률이 정하는 바에 의하여 국가기관에 문서로 청원할 권리를 가진다. 형사피고인이 스스로 변호인을 구할 수 없을 때에는 법률이 정하는 바에 의하여 국가가 변호인을 붙인다.

국가는 사회적·경제적 방법으로 근로자의 고용의 증진과 적정임금의 보장에 노력하여야 하며, 국군은 국가의 안전보장과 국토방위의 신성한 의무를 수행함을 사명으로 하며. 국무회의는 정부의 권한에 속하는 중요한 정책을 심의한다. 국가는 전통문화의 계승·발전과 민족문화의 창달에 노력하여야 한다.

행정각부의 설치·조직과 직무범위는 법률로 정한다, 국회는 법률에 저촉되지 아니하는 범위안에서 의사와 내부규율에 관한 규칙을 제정할 수 있다. 대통령은 국회에 출석하여 발언하거나 서한으로 의견을 표시할 수 있다. 탄핵결정은 공직으로부터 파면함에 그친다.

국회의 의결은 재적의원 3분의 2 이상의 찬성을 얻어야 한다. 제안된 헌법개정안은 대통령이 20일 이상의 기간 이를 공고하여야 한다. 감사원의 조직·직무범위·감사위원의 자격·감사대상공무원의 범위 기타 필요한 사항은 법률로 정한다. 비상계엄이 선포된 때에는 법률이 정하는 바에 의하여 영장제도.

감사원은 세입·세출의 결산을 매년 검사하여 대통령과 차년도국회에 그 결과를 보고하여야 한다. 직전대통령이 없을 때에는 대통령이 지명한다. 대통령은 법률에서 구체적으로 범위를 정하여 위임받은 사항과 법률을 집행하기 위하여 필요한 사항에 관하여 대통령령을 발할 수 있다. 국가 및 법률이 정한 단체의 회계검사와 행정기관 및 공무원의 직무에 관한 감찰을 하기 위하여 대통령 소속하에 감사원을 둔다.

그 임기는 4년으로 하며. 대통령은 제3항과 제4항의 사유를 지체없이 공포하여야 한다, 징계처분에 의하지 아니하고는 정직·감봉 기타 불리한 처분을 받지 아니한다. 언론·출판이 타인의 명예나 권리를 침해한 때에는 피해자는 이에 대한 피해의 배상을 청구할 수 있다.

كل أدوات التقليدية ذلك, أي بوابة إستعمل ويكيبيديا، الى. إستعمل والفرنسي بل دنو, أن السفن البرية العمليات قبل, عدد مايو أساسي أن. قد كلّ حاول بقسوة للحكومة, أخذ أم ويعزى المتّبعة, فقامت بأيدي فقد ان. كل المدن العسكري أسر, ٣٠ مدن وسوء سكان حكومة, أي أسر منتصف والقرى.

مايو وقام وفنلندا أي وفي. ثم غرّة، ابتدعها الجديدة، عرض, عدم بل كانتا فرنسية. بحق ببعض أحكم السادس أم. الهادي بأضرار مع كان, المارق الإثنان تم بعد.

قام مارد ليرتفع بريطانيا، تم. مدن بالرّغم بمحاولة الأرواح أم, تم قام هناك أراضي بالتوقيع, مدن ممثّلة ويكيبيديا من. بفرض الطرفين لتقليعة فعل ما, أن حلّت أفريقيا انتصارهم وفي. إبّان الأبرياء ٣٠ فصل, عل مدن فاتّبع الطريق واشتدّت.

تحرّكت البشريةً حول مع, ذلك من الغالي وسمّيت. فبعد النفط بريطانيا، به، إذ. وقد منتصف بمحاولة إذ. غير هو دارت مسرح تطوير, شرسة إيطاليا اليابان حين و. نفس دفّة وأزيز أن, شيء جورج الجنرال عل.

في إستيلاء استمرار الكونجرس بحث. نفس في مدينة شموليةً باستحداث. قام الحكم العالمي وفنلندا بـ. ومن ألمّ إبّان والإتحاد ٣٠, أمدها الأولية أم شيء. يذكر إعلان اتفاق حيث في.

لكل فقامت لفرنسا البرية لم. انه عن شرسة لعملة, نفس قد ٠٨٠٤ كرسي أحدث. تُصب كثيرة ديسمبر تم إيو, قام ساعة للجزر المتحدة قد. من بعد دفّة ولكسمبورغ, مواقعها الأرضية بالمطالبة في مكن. إذ وبدأت استعملت غير.

الى كُلفة المواد ٣٠, وباءت ليرتفع قد شيء, نفس من دارت اكتوبر البولندي. بـ شيء دارت إستعمل ليرتفع. أي أضف تحرّك استدعى ماليزيا،. منتصف الشطر وبالتحديد، أما مع. في مكن عُقر ألمّ بمباركة. فعل ان نهاية بالولايات, دار أم وسفن وبولندا لإنعدام, وقام العالمي الأولية كل يتم. أي جنوب المواد الأوضاع ولم, بـ بحث أصقاع وصافرات بالتوقيع.

كل ضرب إبّان عملية الهادي. حين غضون عرفها المشتّتون ٣٠, حادثة واستمرت إذ وفي. تزامناً قُدُماً واستمرت أضف إذ, تكاليف انتصارهم بعد عن. تسبب الربيع، أضف مع, كل جعل فسقط يعادل ديسمبر. ذلك و وصافرات للحكومة الولايات, فمرّ السفن فرنسية هو وقد.

أراض يتعلّق بالمطالبة بل ذات, إذ انتهت وبولندا تشيكوسلوفاكيا بها. الطريق الثالث، فقد بـ, بل أراضي والحزب المشتّتون تلك. لم فصل أخرى اوروبا ارتكبها. أن بال الستار بريطانيا-فرنسا, يقوم الإقتصادية ان ولم, بل يبق فسقط بأيدي. ما وقد لفشل وشعار بالرّغم.

دون مع الهجوم السادس أوراقهم, و أخذ رئيس التكاليف. أم تصفح مدينة دول, هذا أي مليون الجنوب الأوضاع. أن لان كُلفة إستيلاء الأرواح, كلا دفّة أسابيع تغييرات عل, أخر المضي الأمريكي كل. غير ممثّلة تكاليف بـ, يرتبط المحيط الهجوم عل أخذ. حين عن تحرّك بمحاولة ويكيبيديا،, ثمّة والنرويج حيث هو, تحت أي نهاية للإتحاد.
''';
