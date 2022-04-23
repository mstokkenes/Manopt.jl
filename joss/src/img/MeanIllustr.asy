import settings;
import three;
import solids;unitsize(4cm);

currentprojection=perspective( camera = (0.7, 0.7, 0.5), target = (0.0, 0.0, 0.0) );
currentlight=nolight;

revolution S=sphere(O,0.995);
pen SpherePen = rgb(0.85,0.85,0.85)+opacity(0.6);
pen SphereLinePen = rgb(0.75,0.75,0.75)+opacity(0.6)+linewidth(0.5pt);
draw(surface(S), surfacepen=SpherePen, meshpen=SphereLinePen);

/*
  Colors
*/
pen pointStyle1 = rgb(0.9333333333333333,0.4666666666666667,0.2)+linewidth(3.5pt)+opacity(1.0);
pen pointStyle2 = rgb(0.2,0.7333333333333333,0.9333333333333333)+linewidth(2.5pt)+opacity(1.0);
pen pointStyle3 = rgb(0.0,0.6,0.5333333333333333)+linewidth(3.5pt)+opacity(1.0);

/*
  Exported Points
*/
dot( (0.6324137793343212,0.5503749556568275,0.5451056960753807), pointStyle1);
dot( (0.6205533398958909,0.5716327709739643,0.5367956105378303), pointStyle2);
dot( (0.7928814204272021,0.40689592010742626,0.4536240330287555), pointStyle3);
dot( (0.6392821835183016,0.6085433634205791,0.47009920726676596), pointStyle3);
dot( (0.22423655032848683,0.9678784957750467,-0.11370658254038313), pointStyle3);
dot( (0.6407839693266083,0.39483528700214277,0.658407928864752), pointStyle3);
dot( (0.5207750137458975,-0.5488141598633577,0.6539085585855542), pointStyle3);
dot( (0.21528473177598395,0.8491451398268158,0.48229142203924824), pointStyle3);
dot( (-0.004727810623989748,0.4889969192764666,0.8722726986125546), pointStyle3);
dot( (0.6537810110887274,0.7272390401272909,0.20903054335321003), pointStyle3);
dot( (0.6307104450262095,0.7675315872632369,-0.1144534712798918), pointStyle3);
dot( (0.6373716206992944,0.7397332274578485,0.21575951733805393), pointStyle3);
dot( (0.6372981602022818,0.12670492793835725,0.7601295391174603), pointStyle3);
dot( (0.7718223377469589,0.54023469680515,0.33531589780782434), pointStyle3);
dot( (0.3124376660444501,-0.9402816168741357,0.13510435154079128), pointStyle3);
dot( (0.8805161624394053,0.05335810429838933,0.47100339742794345), pointStyle3);
dot( (0.4819474695486221,0.6941234577810123,0.5347141871633962), pointStyle3);
dot( (0.397661469860854,0.7375697340625906,0.5457620752516105), pointStyle3);
dot( (0.23711761668193382,0.6633883866560775,0.7097119727811604), pointStyle3);
dot( (0.8493979966142317,0.07949810824649778,0.5217308636959845), pointStyle3);
dot( (0.09619900943987225,0.7652915922463821,0.6364546562165954), pointStyle3);
dot( (0.43431902933893723,0.44982040463198886,0.7804028346506675), pointStyle3);
dot( (0.08636267652618185,0.9850361881660379,0.1491482353450962), pointStyle3);
dot( (0.3439738714163942,0.7888807277764813,0.5092633632273846), pointStyle3);
dot( (0.4798856678356083,0.14590850188489457,0.8651129723242382), pointStyle3);
dot( (-0.0378044830028364,0.8902540183412415,0.45389272288962806), pointStyle3);
dot( (0.8477751498939892,0.5252422991369319,0.07346987423137641), pointStyle3);
dot( (0.13915355728207263,0.48799259958679303,0.8616841127955586), pointStyle3);
dot( (0.7601670506517452,0.4402760538133395,0.47781068588090514), pointStyle3);
dot( (0.44738168000831213,0.2514115980994897,0.8582784167937587), pointStyle3);
dot( (0.5615453400727421,0.6698788878551496,0.4857253407518869), pointStyle3);
dot( (0.559992828653551,0.8042381043976841,0.1990203589872529), pointStyle3);
dot( (0.8962219201803882,-0.039468477468096286,0.4418467031386887), pointStyle3);
dot( (0.49319528255207545,0.5551669377613241,0.6697373249902479), pointStyle3);
dot( (0.7329880283343353,0.6376208135041411,0.23699841456191462), pointStyle3);
dot( (0.8534111669929838,-0.1954464727964681,0.4832080880149808), pointStyle3);
dot( (0.9204028820364004,0.3899977003321569,0.027574054375762047), pointStyle3);
dot( (0.6867882131643065,0.5665967468822517,0.4552911998721574), pointStyle3);
dot( (0.26498991369664493,0.905449143717356,0.3315753214287094), pointStyle3);
dot( (0.538776420642331,0.5678756924374654,0.6222838311401857), pointStyle3);
dot( (0.9509610578491027,0.24743173699214666,0.18560873358644792), pointStyle3);
dot( (0.17774321223593242,0.920933931567451,0.3468256683000408), pointStyle3);