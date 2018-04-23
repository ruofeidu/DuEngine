// XsycRW
highp ivec2 SV_DispatchThreadID = ivec2(0,0);
highp int Double_pixelID = 0;
highp vec4 col = vec4(0.,0.,0.,0.);
int i = 616;

//pass !
void A(vec4 data){
    if(Double_pixelID == i++){
        col = data;
    }
}
void A(uvec4 data){
    if(Double_pixelID == i++){
        col = uintBitsToFloat(data);
    }
}

void mainImage( out vec4 C, in vec2 U)
{
    SV_DispatchThreadID = ivec2(floor(U-0.5));
    if(SV_DispatchThreadID.x >= 48 || SV_DispatchThreadID.y >= 77){
    	C = vec4(1./3.);
        return;
    }
    if(iFrame > 2){
    	C = texture(iChannel0,U/iResolution.xy);
        //discard;
    }
    //1个像素存一个数据块
    //16 x 32, 16为其中2个像素存2个块数据
    //像素ID编号
    Double_pixelID = (SV_DispatchThreadID.x>>1) + (SV_DispatchThreadID.y*24); 
    //-------------------------------------------------------------------------
	A(uvec4(0x31B45A05u,0x3A17BF6Fu,0x25700B06u,0x2DB46F1Bu));
	A(uvec4(0x212E5F0Bu,0x2550BFBFu,0x1CEB1B06u,0x254EAF6Fu));
	A(uvec4(0x4231F0Bu,0x1CEABF7Fu,0x442E4F0u,0xC65E7D4u));
	A(uvec4(0xC65A6EDu,0x148694A6u,0x10A6D5FDu,0x14A79494u));
	A(uvec4(0x14A7B9BEu,0x1CE890A4u,0x14A40601u,0x14A65707u));
	A(uvec4(0xFFFFu,0x1484FFFFu,0xFFFFu,0x1484FFFFu));
	A(uvec4(0xFFFFu,0x1484FFFFu,0x10830F03u,0x14830F0Fu));
	A(uvec4(0x10830F0Fu,0x10830F0Fu,0xFFFFu,0x1083FFFFu));
	A(uvec4(0xC634004u,0x254A7FF9u,0x1084AED0u,0x254A5559u));
	A(uvec4(0x14C59966u,0x2129F0B9u,0x14A66605u,0x1D088756u));
	A(uvec4(0x10A58DEFu,0x18C7FB9Bu,0x10A51A52u,0x18C76B6Eu));
	A(uvec4(0x10A54481u,0x14A6F6B8u,0x10A50B0Bu,0x14A59101u));
	A(uvec4(0x14A5F9F9u,0x1CE7F4F0u,0x2129D0A9u,0x31ACF8E4u));
	A(uvec4(0x31ACD6A4u,0x821055A4u,0x39EEA297u,0x8210E7C8u));
	A(uvec4(0x39CE34B5u,0x86307EEAu,0x318C5A1Fu,0x8210061Au));
	A(uvec4(0x18A52B6Bu,0x318C0A1Au,0x1CC7E0D0u,0xB37BF9F4u));
	A(uvec4(0xB79C1814u,0xBBBD2231u,0xB37BDEDEu,0xBBBCF4F9u));
	A(uvec4(0xB37B6FABu,0xBBBD552Au,0xB79C14C0u,0xBFDE4040u));
	A(uvec4(0xB77BFFFFu,0xBB9C3A3Du,0x14A70B0Bu,0xB37C1F1Fu));
	A(uvec4(0x1087E4F4u,0x108890E8u,0x1088E8F8u,0x14CA90D0u));
	A(uvec4(0x18CBD0E4u,0x2992D0D0u,0x31D4E4E5u,0x3A17E4D4u));
	A(uvec4(0x3A1799D4u,0x8258E4D9u,0x8679E4E4u,0x9AFCF9F8u));
	A(uvec4(0x9B1C7DF8u,0x9F3C845Du,0x96FC192Au,0x9F3D5F1Fu));
	A(uvec4(0x8A9B1A06u,0x96FC5B5Bu,0x3E381B07u,0x8679A71Fu));
	A(uvec4(0x35F60616u,0x3E387F57u,0x29722F2Fu,0x31D5AFBFu));
	A(uvec4(0x254F1919u,0x29725F1Fu,0x212D1B0Bu,0x254FBF6Fu));
	A(uvec4(0x1D0A1A06u,0x212E5B1Au,0xC650B02u,0x1CEABF6Fu));
	A(uvec4(0xC65FAFEu,0x1085F3F9u,0x1085FFFFu,0x1086FCFFu));
	A(uvec4(0x1086F9F9u,0x14C7E4F5u,0x14A50707u,0x14C70B17u));
	A(uvec4(0x14A40A05u,0x18A45B1Eu,0xFFFFu,0x1484FFFFu));
	A(uvec4(0xFFFFu,0x1484FFFFu,0x10830F0Fu,0x1483030Fu));
	A(uvec4(0x10830F0Fu,0x10830003u,0xFFFFu,0x1083FFFFu));
	A(uvec4(0x14C65E6Du,0x21295915u,0x14C6E4D1u,0x1D08FDE8u));
	A(uvec4(0x18C6D6E0u,0x2529A994u,0x18E71A16u,0x25291F5Bu));
	A(uvec4(0x14C66104u,0x21295B59u,0x14A54B65u,0x18C7F1B7u));
	A(uvec4(0x10A51E19u,0x14C6FEEFu,0x1085D91Fu,0x14A6ABD3u));
	A(uvec4(0x14C6D0D4u,0x2128A4F0u,0x2549E4F4u,0x35CDE499u));
	A(uvec4(0x35CD7050u,0x820F9D24u,0x3DEE7D59u,0x8A51797Cu));
	A(uvec4(0x39CE0B6Fu,0x82305D5Au,0x20E86F6Bu,0x35AD276Fu));
	A(uvec4(0x2509A000u,0xB79CF8F4u,0x81CEF8FCu,0xBB7BC3F1u));
	A(uvec4(0xBB9C6E8Au,0xBBBCA038u,0xB37B5691u,0xBBBC9B5Au));
	A(uvec4(0xBB9CF8D0u,0xBFFEE9FDu,0xB39C1F06u,0xBFFFE96Au));
	A(uvec4(0xAB19BEBFu,0xBBBCF3B9u,0x14862F1Fu,0xB77CBF7Fu));
	A(uvec4(0xC45FEFFu,0xC87FEFCu,0x1087E9E4u,0x14A9E4E5u));
	A(uvec4(0x14CBD0D0u,0x2550D0D0u,0x2DB3F9F9u,0x3A16F4F4u));
	A(uvec4(0x35F6E5E9u,0x86784080u,0x8258FEFAu,0x96FC00F9u));
	A(uvec4(0x8A78FFFFu,0x9B1C50AFu,0x92BAFFFFu,0x9B1C40FFu));
	A(uvec4(0x8EBB7B17u,0x96FCC9EAu,0x3E380B06u,0x8EBB6F2Fu));
	A(uvec4(0x36179565u,0x82590706u,0x2DB41702u,0x35F66F2Fu));
	A(uvec4(0x25710A05u,0x2DB41B1Au,0x214E0B0Fu,0x25700606u));
	A(uvec4(0x1D0C1F1Au,0x1D2E5B1Fu,0x1D0A1A00u,0x1D0C2F1Fu));
	A(uvec4(0xC850B06u,0x18E9BF6Fu,0xC65FFFFu,0x1065F3FFu));
	A(uvec4(0x1065E5EAu,0x14A69495u,0x14A50A0Bu,0x14C71516u));
	A(uvec4(0x14A4171Fu,0x18A41F17u,0xFFFFu,0x1484FFFFu));
	A(uvec4(0x1483333Fu,0x14843333u,0x10830303u,0x14830303u));
	A(uvec4(0xFFFFu,0x1083FFFFu,0xFFFFu,0x1063FFFFu));
	A(uvec4(0x1CE79996u,0x2129E8F8u,0x1CE74454u,0x296BA6DAu));
	A(uvec4(0x1D08B41Eu,0x254A9AE6u,0x1CE7A85Au,0x2D6BF0B4u));
	A(uvec4(0x14C60B67u,0x2108FFABu,0x14C60D04u,0x2129A256u));
	A(uvec4(0x14A55629u,0x18E76EAFu,0x14A60404u,0x1D08D590u));
	A(uvec4(0x18E7F0A0u,0x2529D094u,0x2549E5E4u,0x39EEEDF9u));
	A(uvec4(0x39ED79A4u,0x86506F3Du,0x3DEEF1F7u,0x82301D68u));
	A(uvec4(0x2D6B7FBFu,0x3DEE0B1Fu,0x25090000u,0xA2F7C040u));
	A(uvec4(0x3DCFFDFCu,0xBBBDFFFFu,0x81AC1F4Bu,0xBB9CBF7Fu));
	A(uvec4(0x81ADFEFFu,0xBB9CF4F8u,0xB79C2905u,0xBBBD20BAu));
	A(uvec4(0xB79CA8A4u,0xBFFEFDF8u,0xB39CE1F5u,0xBFFFFEF9u));
	A(uvec4(0xA718C3D3u,0xBBBDD3C3u,0xA2D87F3Bu,0xBB9C7B7Fu));
	A(uvec4(0xC664342u,0x250A0243u,0x1087D5D5u,0x14A9D094u));
	A(uvec4(0x14CAD0D0u,0x2550D0D0u,0x31D468B4u,0x3A164000u));
	A(uvec4(0x35F65050u,0x8E9BFAA4u,0x39F61605u,0x8A7ABF1Bu));
	A(uvec4(0x2D9346E6u,0x3E171B06u,0x2D92A4FEu,0x8A780000u));
	A(uvec4(0x2D91AAFFu,0x8A994055u,0x31D3BEFFu,0x8A9A0055u));
	A(uvec4(0x35F56A1Fu,0x3E3800ABu,0x2DB45606u,0x35F65A6Bu));
	A(uvec4(0x21710717u,0x2DB41B0Bu,0x1D2E5B5Bu,0x2170476Au));
	A(uvec4(0x1D0C1B1Bu,0x1D2E561Bu,0x1D0CF0FCu,0x1D0CF5F4u));
	A(uvec4(0x14C86B1Bu,0x1D0BBFAFu,0x10650601u,0x18E91F0Bu));
	A(uvec4(0x1064F5F5u,0x1485F9F8u,0x18A52919u,0x18A50B29u));
	A(uvec4(0x14A41A1Au,0x18A51B1Au,0xFFFFu,0x1484FFFFu));
	A(uvec4(0xFFFFu,0x1484FFFFu,0x10830303u,0x14830F03u));
	A(uvec4(0xFFFFu,0x1083FFFFu,0xFFFFu,0x1063FFFFu));
	A(uvec4(0x1CE7E9E0u,0x2529F9FDu,0x25290400u,0x2D6B6D6Du));
	A(uvec4(0x2108EDB8u,0x25297F9Du,0x18E799D4u,0x294AAA6Au));
	A(uvec4(0x21290705u,0x31AD2C06u,0x18E72A65u,0x25296A97u));
	A(uvec4(0x14C62955u,0x2108AB6Bu,0x14C6FDF4u,0x1CE7FBADu));
	A(uvec4(0x1CE7E8F4u,0x254AD4D5u,0x2D8BB890u,0x822FE9E5u));
	A(uvec4(0x3DEEF0BAu,0x8651F9A4u,0x35AC1B6Fu,0x82301517u));
	A(uvec4(0x1CC76EAFu,0x35CD061Au,0x20E8F0D0u,0xB39CFDF8u));
	A(uvec4(0xBBBC94A5u,0xBBBDB5E5u,0xBB7BFF3Fu,0xBBBDBFFFu));
	A(uvec4(0x396B83E1u,0xB77B1F4Bu,0x9632FEFFu,0xB79BE8F9u));
	A(uvec4(0xB79CD1E8u,0xBFFE0000u,0xB35B2BFFu,0xBFFF455Au));
	A(uvec4(0xA2D7BDF4u,0xBB9CFEBFu,0x14657FBFu,0xBB9C0B2Fu));
	A(uvec4(0x843B4FEu,0xC659155u,0xC64E5EAu,0x1088F9E4u));
	A(uvec4(0x14CAE090u,0x31B4E4E4u,0x31B450E4u,0x8218AE14u));
	A(uvec4(0x39B650FFu,0x8659B590u,0x3DF754BFu,0x8A7A0100u));
	A(uvec4(0x35D56F1Fu,0x82395969u,0x29716F15u,0x39D6BFBFu));
	A(uvec4(0x25500550u,0x3194BF1Bu,0x212FA5FFu,0x2D920601u));
	A(uvec4(0x212EFAFFu,0x2DB350A5u,0x25716AAFu,0x31D50055u));
	A(uvec4(0x2570061Bu,0x2DB30505u,0x1D2E0747u,0x25700206u));
	A(uvec4(0x190C7F77u,0x1D0D7F3Fu,0x190CF5FAu,0x1D0CF9F4u));
	A(uvec4(0x190B5B1Bu,0x1D0CA756u,0x10862F1Fu,0x1D0ABF7Fu));
	A(uvec4(0xC65F8E4u,0x14A5FFF9u,0x14A5FFFFu,0x18A53FFFu));
	A(uvec4(0x14A45717u,0x14A55757u,0xFFFFu,0x1484FFFFu));
	A(uvec4(0xFFFFu,0x1484FFFFu,0x10831705u,0x14845F5Fu));
	A(uvec4(0x10830F00u,0x10830F0Fu,0xFFFFu,0x1063FFFFu));
	A(uvec4(0x1CE7F8F8u,0x2549F9E8u,0x2529F950u,0x2D6BFAEAu));
	A(uvec4(0x25298701u,0x2D6BFE97u,0x2128B854u,0x296B9BFDu));
	A(uvec4(0x2529617Cu,0x2D8C8AC9u,0x25290601u,0x31AD570Au));
	A(uvec4(0x18E73CBAu,0x2109FB8Au,0x18E74DF8u,0x1D08D387u));
	A(uvec4(0x21285040u,0x8210E490u,0x39EEB8C0u,0x8651B5F9u));
	A(uvec4(0x35AD9BABu,0x86501A57u,0x29296B6Bu,0x3DEE125Au));
	A(uvec4(0x25084000u,0xAF5BE0D0u,0x9AD6FEFCu,0xBBBDFFFFu));
	A(uvec4(0xBBBCFFFFu,0xBBBDF7F4u,0xB7BD4B56u,0xBBBDAF1Eu));
	A(uvec4(0x3D8CBF2Fu,0xBBBDFFFFu,0x3109E4F8u,0xAAF787D2u));
	A(uvec4(0xA2B5FDFFu,0xB79BE4F9u,0xB35B2A1Bu,0xBBBD2546u));
	A(uvec4(0x14667FFFu,0xBB9C010Bu,0x10670003u,0x8A110000u));
	A(uvec4(0xC664000u,0x31B3F9A0u,0xC660500u,0x31B3AF56u));
	A(uvec4(0xC67D4E4u,0x82160100u,0xC69FFFFu,0x8A3990F9u));
	A(uvec4(0x8A3ABA10u,0xB39E54FEu,0x82186F05u,0x9ADB5B6Fu));
	A(uvec4(0x39D60A01u,0x8E7A6A1Fu,0x35B50400u,0x8A387E15u));
	A(uvec4(0x2531065Au,0x35B41B1Bu,0x210F6F2Fu,0x29710095u));
	A(uvec4(0x1D0C0A45u,0x254F7E2Fu,0x1D0CE9FEu,0x25704090u));
	A(uvec4(0x1D2EBFFFu,0x2570016Au,0x1D2D1B5Bu,0x214F5519u));
	A(uvec4(0x1D0D1F6Fu,0x1D2D9F7Fu,0x1D0CA594u,0x1D2DFFE9u));
	A(uvec4(0x190C4645u,0x1D2D4346u,0x1CE96B1Bu,0x1D0CAF6Fu));
	A(uvec4(0x14A51612u,0x1CE91B17u,0x14A45F7Fu,0x18A51D55u));
	A(uvec4(0x14A40F0Fu,0x14A40030u,0xFFFFu,0x14A4FFFFu));
	A(uvec4(0xFFFFu,0x1484FFFFu,0xFFFFu,0x1484FFFFu));
	A(uvec4(0x10835705u,0x1483D17Fu,0x10835605u,0x1483AF5Au));
	A(uvec4(0x1CE7FCFDu,0x2129FFFEu,0x2529F4F9u,0x2D6BE0F4u));
	A(uvec4(0x2549B63Fu,0x2D6BB2A2u,0x2549BF54u,0x2D6BFEFEu));
	A(uvec4(0x25292F1Fu,0x2D6BBFBFu,0x25296D7Fu,0x35ADF1F4u));
	A(uvec4(0x1CE85BA6u,0x294A1F1Bu,0x18E75441u,0x2D6BF9E4u));
	A(uvec4(0x2D8BE8E4u,0x3E0FFEF9u,0x39EEA65Bu,0x86512F3Du));
	A(uvec4(0x2D6B2F3Fu,0x3DEF0507u,0x25290000u,0x96B5C040u));
	A(uvec4(0x20E7FDF4u,0xB79CFFFEu,0xBBBCFFFFu,0xBBBDF3FFu));
	A(uvec4(0xBBBDFDF4u,0xBBBDD1FDu,0xBBBD5F05u,0xBBBD015Fu));
	A(uvec4(0xB79C56E6u,0xBBBD15D6u,0x352A2F0Bu,0xBB9CFF7Fu));
	A(uvec4(0x3129F8FEu,0xA2D681E0u,0x250C7F7Fu,0xB35A3E7Eu));
	A(uvec4(0x823E9A4u,0x14A9F9F9u,0x14A9E994u,0x31D3F9F9u));
	A(uvec4(0x2991E590u,0x8E9AF9F9u,0x35936A05u,0x9AFCFFAFu));
	A(uvec4(0x29304500u,0x92BAAF5Au,0x108B1601u,0x39D6FFAAu));
	A(uvec4(0x14ABE0FDu,0x86186A41u,0x2952FFFFu,0x86180090u));
	A(uvec4(0x2952FFFFu,0x3DD700EBu,0x2D73FFFFu,0x86180096u));
	A(uvec4(0x29521B07u,0x81F86E5Bu,0x1CEE0606u,0x29526B17u));
	A(uvec4(0x18EC95E5u,0x254E1506u,0x190C1A07u,0x254E5469u));
	A(uvec4(0x190CA4F8u,0x1D2E6659u,0x190CBFFFu,0x1D0D546Au));
	A(uvec4(0x190C9D96u,0x1D2DF4EDu,0x1D2D9040u,0x214FF9E5u));
	A(uvec4(0x190C5642u,0x1D4E9B57u,0x1D0B5B0Au,0x214EAF5Fu));
	A(uvec4(0x14A51B17u,0x1D0B5F1Bu,0x14A41A1Eu,0x18A45555u));
	A(uvec4(0x14A4FDF4u,0x18A5FFFFu,0xFFFFu,0x18A5FFFFu));
	A(uvec4(0xFFFFu,0x18A5FFFFu,0x14845A15u,0x18A5AF6Bu));
	A(uvec4(0x1483FFF3u,0x1484FFFFu,0x1083FF3Fu,0x1484FFFFu));
	A(uvec4(0x2108F9E1u,0x2549A4E6u,0x2129E1E1u,0x296BE0F5u));
	A(uvec4(0x296BDA80u,0x318C96A4u,0x25496B1Bu,0x2D8BBFBFu));
	A(uvec4(0x294A8659u,0x2D8C2E45u,0x21298EC6u,0x2D8B3F1Eu));
	A(uvec4(0x21290706u,0x35ADA85Au,0x2129E4E0u,0x39EEFAF9u));
	A(uvec4(0x3E0FF8A0u,0x86510415u,0x318C1A1Fu,0x86310006u));
	A(uvec4(0x20E82A6Au,0x81F0C106u,0x2109F4E0u,0xB39CFFFDu));
	A(uvec4(0xBBBC5081u,0xBBDDA839u,0xBBBC3FF0u,0xBBBDFFDFu));
	A(uvec4(0xBB9DF7AFu,0xBBBDC7F3u,0xBBBC5F55u,0xBBBD015Fu));
	A(uvec4(0xB79CD515u,0xBBDD2625u,0xB79C4C66u,0xBBBC0256u));
	A(uvec4(0x2908AF47u,0xAF396FBFu,0x18CB0B2Fu,0xA6F80002u));
	A(uvec4(0x10A99040u,0x1D0EEF95u,0x212DE4E4u,0x3A16F9F4u));
	A(uvec4(0x35F5A5D0u,0x8E9AEAFAu,0x92BA94F9u,0x9F1D4004u));
	A(uvec4(0x92BBFF1Bu,0x9B1CF4FAu,0x8639AF01u,0x9B1CFFFFu));
	A(uvec4(0x35D6BF05u,0x8EBABBFFu,0x2D731601u,0x8A7AFFBFu));
	A(uvec4(0x29530100u,0x867ABF16u,0x29520040u,0x3E381B01u));
	A(uvec4(0x2130FAFFu,0x35B500D0u,0x25301605u,0x3194015Fu));
	A(uvec4(0x18EC0611u,0x252F2F1Fu,0x14CA90F4u,0x1D0C0600u));
	A(uvec4(0x14CBAEBFu,0x1D0DA8BDu,0x18EBFEFEu,0x190CF1FDu));
	A(uvec4(0x190C94A4u,0x1D2ED0D0u,0x1D2EE490u,0x2991F9E4u));
	A(uvec4(0x1D2D0605u,0x29B21B0Au,0x1D2D5E1Au,0x256F6E5Eu));
	A(uvec4(0x18C71B1Bu,0x212C6F2Fu,0x14A50000u,0x14A60301u));
	A(uvec4(0x18A5F994u,0x18C5F8F9u,0x18C50000u,0x1CC5F880u));
	A(uvec4(0x18C50000u,0x1CC5BF0Au,0x14A56B1Au,0x18A5BF6Fu));
	A(uvec4(0x14A41605u,0x18A56B5Au,0xFFFFu,0x1484FFFFu));
	A(uvec4(0x21291000u,0x254A6B75u,0x2108D0D0u,0x296BE5E5u));
	A(uvec4(0x294A51A6u,0x318CF965u,0x296BBE1Au,0x31AC5FAEu));
	A(uvec4(0x2D8B1558u,0x35AD6E19u,0x296B910Bu,0x31ADEFEAu));
	A(uvec4(0x2128F1F9u,0x318CEFEAu,0x31ACFCF5u,0x3DEFAABDu));
	A(uvec4(0x2D6B6FBFu,0x3DEF161Au,0x20E81BAAu,0x35AD8106u));
	A(uvec4(0x20E8E4D0u,0xB79CFEF9u,0xB79C7AE1u,0xBBBDFBADu));
	A(uvec4(0xBBBD19E6u,0xBBBD75D3u,0xBB9CEFBBu,0xBBBD3EF6u));
	A(uvec4(0xBBBCEAFEu,0xBBDDB1AEu,0xB79BAD66u,0xBBBE149Fu));
	A(uvec4(0xB35BBFEFu,0xBBBC062Bu,0x3DF3BFFFu,0xB37A811Fu));
	A(uvec4(0x2D71910Bu,0x96DAFFFEu,0x2D925B00u,0x8A79BF6Fu));
	A(uvec4(0x1D2F4140u,0x31B41B07u,0x1D0FF9F9u,0x39F6E4E9u));
	A(uvec4(0x3A17E4E4u,0x8E9980E0u,0x8E9AE5E0u,0x9AFCF4E0u));
	A(uvec4(0x96DB1900u,0xA33D696Eu,0x92BA0A1Au,0x9AFC0B5Fu));
	A(uvec4(0x82579101u,0x92DBFBEBu,0x3A165601u,0x8A9A2FBBu));
	A(uvec4(0x31D415E9u,0x8A9B005Au,0x2992F9BFu,0x8A7A0001u));
	A(uvec4(0x21305B05u,0x825850AAu,0x1D0E0101u,0x2DB2BF1Bu));
	A(uvec4(0x1CED1410u,0x212FAF24u,0xC68E5BFu,0x18ECBF0Bu));
	A(uvec4(0xC88EFFAu,0x1D0C50E9u,0x14ECEBC6u,0x1D0CEDABu));
	A(uvec4(0x190D8081u,0x254FAE58u,0x2570D490u,0x31D3E4E4u));
	A(uvec4(0x1D2E1F1Bu,0x2DD36F2Fu,0x1D2EF8BDu,0x256FF4F4u));
	A(uvec4(0x1D0A1B07u,0x214E1F1Bu,0x18A50202u,0x18E81B07u));
	A(uvec4(0x18A5F4A4u,0x1CC5F5F5u,0x1CC5FFF4u,0x1CC6FFFFu));
	A(uvec4(0x1CC5FF0Fu,0x1CC6FFFFu,0x18A56A16u,0x1CC5AF6Fu));
	A(uvec4(0x14A41F1Bu,0x18A51F1Fu,0xFFFFu,0x14A4FFFFu));
	A(uvec4(0x254A9611u,0x2D6BFFAFu,0x2549D1D0u,0x2D6BEAE5u));
	A(uvec4(0x2D6B95EAu,0x31ACD195u,0x318C591Fu,0x35CDBE7Du));
	A(uvec4(0x2D8C1919u,0x39CEFE6Du,0x2D8C6904u,0x35CEFABAu));
	A(uvec4(0x254A1E85u,0x35CE6F1Fu,0x294ABEFFu,0x39EE5469u));
	A(uvec4(0x2529166Bu,0x39ADC005u,0x292AE080u,0xB39CFEF8u));
	A(uvec4(0xB39CEDA4u,0xBBBDFBBAu,0xBB9CEFBFu,0xBBBD2BEFu));
	A(uvec4(0xBBBDFBAAu,0xBFDE075Eu,0x2508FFFFu,0xBBBC00BFu));
	A(uvec4(0x18A5FFFFu,0xBBBD0016u,0x20E76BFFu,0xBBBC0400u));
	A(uvec4(0x358EA9BFu,0xAF3A9594u,0x18C8FFFEu,0x8A7850A5u));
	A(uvec4(0x2DB4FEFFu,0x96FBF8FAu,0x82581B07u,0x96FB6F5Bu));
	A(uvec4(0x25721A06u,0x82596B6Bu,0x1D0F81E0u,0x35D51A06u));
	A(uvec4(0x2551A9EAu,0x863850A4u,0x3A17E4FEu,0x8E9AE4E0u));
	A(uvec4(0x8EBA0059u,0x9F3EFE10u,0x8658005Au,0x9F3CFF94u));
	A(uvec4(0x8678051Au,0x92DB7F6Fu,0x2D922F1Bu,0x8257BFBFu));
	A(uvec4(0x212F0645u,0x31B31F1Bu,0x10AA0BE7u,0x212F1A1Eu));
	A(uvec4(0xC88FEFFu,0x1D2E90A5u,0x18EBFDFFu,0x299150F9u));
	A(uvec4(0x1CEDBF1Eu,0x2970AFFFu,0x18EC0104u,0x2550BF1Bu));
	A(uvec4(0xCA96A06u,0x1D0DAF5Au,0xC8850E9u,0x1D0C0A05u));
	A(uvec4(0x867FEFFu,0x1D2DD0F5u,0x1D2DE4F9u,0x31D4E0E0u));
	A(uvec4(0x216F1B1Au,0x3A166F1Fu,0x1D2DF4F9u,0x256FE1F5u));
	A(uvec4(0x1D0B1B1Bu,0x256F1B1Bu,0x18C60B07u,0x1CE90B0Bu));
	A(uvec4(0x18C5FDF4u,0x1CC6FFFEu,0xFFFFu,0x1CC6FFFFu));
	A(uvec4(0xFFFFu,0x1CC6FFFFu,0x1CC51B1Bu,0x1CC61B1Bu));
	A(uvec4(0x14A45F1Bu,0x18C56B5Fu,0x14A47070u,0x14A57474u));
	A(uvec4(0x2D6AA0B5u,0x2D8B90A4u,0x2D6BFD44u,0x31ACF9FDu));
	A(uvec4(0x2D8B9580u,0x35ADE7E6u,0x35AD7C28u,0x39EE5AB8u));
	A(uvec4(0x39EE0C58u,0x3E0F7C18u,0x31AD4797u,0x39EE1F1Bu));
	A(uvec4(0x292AAF6Fu,0x31AD165Bu,0x252A0000u,0x9273D040u));
	A(uvec4(0x292AE490u,0xB39CFFF9u,0xB39CBAA0u,0xBBBDEBE9u));
	A(uvec4(0xBB9DDDEDu,0xBBBEFB63u,0x18A56FFFu,0xBBDE530Bu));
	A(uvec4(0x20E7E003u,0xA7180080u,0x10650BA9u,0x9296F841u));
	A(uvec4(0x18C74001u,0x96B9FFFEu,0x1CE7AF54u,0x8A77FFFFu));
	A(uvec4(0x212A0004u,0x9B1BFFFEu,0x14A8A960u,0xAB5DFFFFu));
	A(uvec4(0x2573FEF8u,0xA75DFFFFu,0x8EBB2F1Bu,0xA33D6F6Fu));
	A(uvec4(0x35D61B06u,0x8EBB6F6Bu,0x25521B06u,0x31D6AF6Fu));
	A(uvec4(0x1D10C0D0u,0x31D50541u,0x2973E9E9u,0x92BBD4E5u));
	A(uvec4(0x9F1DFDF8u,0xA77EF8FCu,0x9F3DBA01u,0xAB9EFFFFu));
	A(uvec4(0x96FC5601u,0xAB7EFFABu,0x82580605u,0xA75E1B0Au));
	A(uvec4(0x25701606u,0x3E376F1Bu,0x18EB5607u,0x212E6F5Bu));
	A(uvec4(0xC874641u,0x1CEB1F0Bu,0xC88E5FEu,0x14EB5054u));
	A(uvec4(0x14CAF8FAu,0x254F90A4u,0x1D2ED6BFu,0x25700444u));
	A(uvec4(0x214FAE5Au,0x299064B5u,0x18EB6F1Au,0x256EFFBFu));
	A(uvec4(0xC87AA91u,0x214EFFFFu,0x190C80E0u,0x31D31501u));
	A(uvec4(0x1D2DBEBFu,0x3E37FCFEu,0x214D4151u,0x2DD20702u));
	A(uvec4(0x1D0B6F2Fu,0x254E6E6Fu,0x1CC61B0Bu,0x1D0A5B5Bu));
	A(uvec4(0x1CE65450u,0x1CE7F575u,0x1CE60201u,0x1CE60702u));
	A(uvec4(0x1CC5FFFFu,0x1CC60F3Fu,0x18C55A6Bu,0x1CC60555u));
	A(uvec4(0x14A47F7Fu,0x18A53F7Fu,0x14A4F574u,0x14A5F4F5u));
	A(uvec4(0x2528A9FAu,0x2D6A54A4u,0x2949E5E9u,0x35ACA4E4u));
	A(uvec4(0x35CD0000u,0x820E2D40u,0x35CDD691u,0x39EEEE5Bu));
	A(uvec4(0x35CDAEAEu,0x3E0F1B1Du,0x29495B6Fu,0x39CE061Au));
	A(uvec4(0x294B0000u,0xB35AF990u,0x294AF9E4u,0xB39CFFFFu));
	A(uvec4(0xB79C5150u,0xBBDEAAC9u,0xBB9CFFFFu,0xBBBDFF3Fu));
	A(uvec4(0x2D49BFFFu,0xBBDD1F3Fu,0x358C196Au,0xA2F9F6D9u));
	A(uvec4(0x1085F480u,0x9AFAFFBFu,0x8A76F4ABu,0xA33CFBFDu));
	A(uvec4(0x96DA291Au,0x9F3CFF6Bu,0x8A78A550u,0xA33D1FFAu));
	A(uvec4(0x8235FEFEu,0xA73D00FFu,0x3E36FFFFu,0xAB5C00FFu));
	A(uvec4(0x8257FFFFu,0xA33C90FFu,0x96DB6B6Fu,0x9F3C64ABu));
	A(uvec4(0x867A0B07u,0x96FC7B1Bu,0x31B65B06u,0x867AAF5Bu));
	A(uvec4(0x21311A06u,0x35F7BF6Fu,0x2551D0D0u,0x8A7AD1D0u));
	A(uvec4(0x8EBAE9FAu,0xA75EE5E8u,0xA35EE0FAu,0xAF9EE0E0u));
	A(uvec4(0xAB7C6E66u,0xB3BF7E1Au,0x8A9A1B1Bu,0xAB7E0B1Bu));
	A(uvec4(0x29B21B1Bu,0x86791B1Bu,0x212D561Au,0x25911B07u));
	A(uvec4(0xC88FF3Fu,0x1D0CFFFFu,0xC670040u,0x212D1F43u));
	A(uvec4(0x10A9FDF9u,0x18EBE4A8u,0x18ECF9FEu,0x212EF0F8u));
	A(uvec4(0x212FFFFFu,0x214F02FFu,0x214FF5E0u,0x256FE8F6u));
	A(uvec4(0x256FF4A5u,0x2DB1B9F9u,0x190C1B1Bu,0x29906F6Fu));
	A(uvec4(0x14EBF4F8u,0x3A37A4F4u,0x1D2C1B07u,0x3A141A1Fu));
	A(uvec4(0x190B3E7Eu,0x212D1129u,0x20E71B1Bu,0x1CEA5F5Bu));
	A(uvec4(0x1CE75650u,0x25076BAAu,0x1CC60706u,0x20E71B0Bu));
	A(uvec4(0x1CC51D1Du,0x1CC51F1Fu,0x18C50300u,0x1CC5030Fu));
	A(uvec4(0x14A46F7Fu,0x18A56F2Fu,0x14A4F5F5u,0x14A595F4u));
	A(uvec4(0x1CE6AAFEu,0x25280565u,0x25499040u,0xA738F4E0u));
	A(uvec4(0x86506A14u,0xA738FFFFu,0x39EE0100u,0xA3160702u));
	A(uvec4(0x39CE0000u,0xA317E440u,0x316BE440u,0xB37BFFFEu));
	A(uvec4(0xA2F8FEF8u,0xB7BCFFFFu,0xBBBCE681u,0xBBBDFEF6u));
	A(uvec4(0xBBBC4FFFu,0xBBBE451Fu,0xAF5BFFFFu,0xBBBD3BFFu));
	A(uvec4(0x318C1B6Fu,0xB39B965Bu,0x821FDF8u,0xA33CFFFEu));
	A(uvec4(0x9AFB5A40u,0xA35C7FAEu,0x8256EBFFu,0x9F3C3BEFu));
	A(uvec4(0x256F0BBFu,0x9B1CF8E2u,0x31B1F900u,0x9B1CFFFFu));
	A(uvec4(0x39F4FF00u,0x9F1CFFFEu,0x31D3FF00u,0x9AFBFFFFu));
	A(uvec4(0x25706B00u,0x96FBFFFFu,0x214E01E9u,0x92DAFF6Fu));
	A(uvec4(0x212EF9FFu,0x92BA1B40u,0x18EDFFFFu,0x8679A4FFu));
	A(uvec4(0x35F77F1Au,0x8239957Eu,0x31B6D5D0u,0x8A9AFAE9u));
	A(uvec4(0x96DCA8D8u,0xA35EE4E4u,0xA35EF4F4u,0xAF9ED5E4u));
	A(uvec4(0xA75E2F7Eu,0xB3BE1F1Fu,0x867A2B6Bu,0x9F3C1B1Bu));
	A(uvec4(0x29921F2Fu,0x3E381B1Bu,0x1D0D6B7Fu,0x25500707u));
	A(uvec4(0x14CB5BDFu,0x1D0C0117u,0x14AABE3Fu,0x212DE9FEu));
	A(uvec4(0xC8891D4u,0x18CB9393u,0x18ECE090u,0x2571E4E0u));
	A(uvec4(0x25505A00u,0x2992EEFAu,0x25704040u,0x2DB3FE9Au));
	A(uvec4(0x2590A524u,0x2DB3FFEEu,0x216F0606u,0x2DB26F5Bu));
	A(uvec4(0x1D2CE5F4u,0x31D35595u,0x1D2D1A2Fu,0x2D910616u));
	A(uvec4(0x190A1B57u,0x1D2B4612u,0x1CEAE1D0u,0x2108F5E1u));
	A(uvec4(0x21070B0Au,0x25071F1Fu,0x1CC55B6Bu,0x20E71B1Bu));
	A(uvec4(0x1CC51E0Au,0x1CC60A5Eu,0x18C50303u,0x1CC50303u));
	A(uvec4(0xFFFFu,0x18A5FFFFu,0x14A41605u,0x18A5BF6Fu));
	A(uvec4(0x1CE61005u,0x21073810u,0x1D27FCF8u,0xAF7AFDFDu));
	A(uvec4(0xAB59AF16u,0xB39CBFFFu,0x318B0707u,0xAB580707u));
	A(uvec4(0x358BF9F9u,0xB37AF8F9u,0xB79C8014u,0xBBBD1030u));
	A(uvec4(0xB79CD751u,0xBBBD54D0u,0xB39CFAA9u,0xBBBD01AAu));
	A(uvec4(0xA33ABFFFu,0xBBBC015Bu,0x4437FBFu,0xAB5B2F7Fu));
	A(uvec4(0x1084D0C0u,0xA33CFCF0u,0xA33C0003u,0xAB7E0000u));
	A(uvec4(0x9F3C1A3Bu,0xA35DD924u,0x256F8F2Fu,0x9B1CF2D7u));
	A(uvec4(0x8A98D7FEu,0x96FB2A40u,0x92D96BEAu,0x9F3CBC2Eu));
	A(uvec4(0x92D9FEBFu,0x9F3C0BF4u,0x96FAFABFu,0x9F1CBC9Bu));
	A(uvec4(0x96FB1609u,0x9F1C0003u,0x8EBA2F7Fu,0x96FB6A57u));
	A(uvec4(0x8A99192Bu,0x92DBADA0u,0x1D2F2F02u,0x8E9AFFFFu));
	A(uvec4(0x214FA4E9u,0x86795F92u,0x3E37F9E9u,0x92DBF8F9u));
	A(uvec4(0x96DBE5D4u,0xA33DF9F9u,0xA35DE5E5u,0xAF9EE4F4u));
	A(uvec4(0x9F1C6FAFu,0xAF9E1B2Fu,0x3E381B1Bu,0x9AFC1B1Fu));
	A(uvec4(0x25712F6Fu,0x35F61B1Bu,0x1D0D0307u,0x214F070Bu));
	A(uvec4(0x10A9F3DBu,0x14CBFBE7u,0x14CAA9FDu,0x1D0C2555u));
	A(uvec4(0xC88D293u,0x18CAD1D1u,0x1D0CA4A4u,0x2992E4E8u));
	A(uvec4(0x29925450u,0x31F5F9A9u,0x2DB3A450u,0x35F5BFBFu));
	A(uvec4(0x2DB35A00u,0x35F6FFAAu,0x29921701u,0x31D45B6Bu));
	A(uvec4(0x256F1B3Au,0x29910F4Fu,0x1D0C1B1Fu,0x254F1A17u));
	A(uvec4(0x18EA56AEu,0x1D0BCB5Bu,0x1CEAE4E0u,0x2528F4E4u));
	A(uvec4(0x21072F1Bu,0x25086F6Fu,0x1CE60706u,0x20E71B1Bu));
	A(uvec4(0x1CC55F0Fu,0x1CC6FFFFu,0x1CC5FE00u,0x1CC6FFFFu));
	A(uvec4(0x18C55500u,0x1CC6FF5Fu,0x18A55A06u,0x1CC5AF6Au));
	A(uvec4(0x1CE6E4A4u,0x2548E8E9u,0x8E93FCFCu,0xAF7AE8F8u));
	A(uvec4(0xA738EFFFu,0xB39B05AFu,0x1CE70307u,0x9F160102u));
	A(uvec4(0x20E7E0F4u,0xA71780D0u,0xA318FEFFu,0xB79C14ADu));
	A(uvec4(0x9AD9BFFFu,0xB79C005Au,0x82361BBFu,0xAF7B0106u));
	A(uvec4(0x8656F4FAu,0xA33BF8F8u,0x10A52F2Fu,0xAB7C6B6Bu));
	A(uvec4(0x18C9FCFCu,0xA35CFCFCu,0xA33C82C0u,0xAB7E4102u));
	A(uvec4(0x296F7FFFu,0xA33C2F3Fu,0x2D90FCF8u,0x9F1BFFFDu));
	A(uvec4(0x92B8FBABu,0xA33CD0B9u,0x96F90B90u,0xA35C1569u));
	A(uvec4(0x96FAFC7Fu,0xA35C05A5u,0x86771BE5u,0x9B3CFFBFu));
	A(uvec4(0x3E56BDAFu,0x96FB0BE5u,0x8698F5BEu,0x92DB0456u));
	A(uvec4(0x8A9956AFu,0x8EBAB8B7u,0x8678FE86u,0x8EBABAFFu));
	A(uvec4(0x31D4FF3Fu,0x92DAFFFFu,0x39F5D0E4u,0x96DB0381u));
	A(uvec4(0x8258FFFFu,0x9F3CE4FAu,0xA75EE0D0u,0xAF9FE0E0u));
	A(uvec4(0x9B1C1B5Bu,0xAFBE061Bu,0x3E370B1Bu,0x96FC060Au));
	A(uvec4(0x214F2B2Bu,0x31D5061Bu,0x14EC5B5Fu,0x1D2E525Bu));
	A(uvec4(0x14EB5641u,0x1D2DEA96u,0x18EB5400u,0x254FFEF9u));
	A(uvec4(0x10A95500u,0x2970FFFEu,0x18EB9494u,0x2DB3FFFAu));
	A(uvec4(0x2DB2F8E4u,0x35F5FFFEu,0x35F57F19u,0x3A16FFFFu));
	A(uvec4(0x31B466AAu,0x3A160717u,0x29921B5Bu,0x31D41A2Fu));
	A(uvec4(0x254F1F0Fu,0x29911B1Fu,0x1D0C1B1Fu,0x212D0F1Fu));
	A(uvec4(0x18EA978Bu,0x1D0B5AA6u,0x1CE9F4E0u,0x2528F4F4u));
	A(uvec4(0x25070505u,0x29281F1Au,0x1CE6BF1Fu,0x2107FFFFu));
	A(uvec4(0x1CE66A05u,0x20E7FFBFu,0x1CE65500u,0x1CE7AB55u));
	A(uvec4(0x1CE61504u,0x1CE7BF5Au,0x1CE60000u,0x1CE60F00u));
	A(uvec4(0x18C5E9FEu,0x2107A4A9u,0x2127F9FDu,0x9EF650A4u));
	A(uvec4(0x25286FFFu,0x9EF6011Au,0x10840657u,0x25280102u));
	A(uvec4(0x14A440C0u,0x2D6A0000u,0x18C695FFu,0x8A53D0D0u));
	A(uvec4(0x8E75F8A4u,0x9ADCBEFDu,0x3A170B1Bu,0x92BA9606u));
	A(uvec4(0x8A98FCF8u,0xA33AF9F9u,0xCA68B47u,0x9F1ACFCFu));
	A(uvec4(0x192DF5FDu,0xA33CB6F1u,0x8696FFFFu,0xA35DFCFFu));
	A(uvec4(0x31D18F0Fu,0xA35CC3C7u,0x96FA669Bu,0xA33C045Bu));
	A(uvec4(0x31D21B9Bu,0x9AFA161Au,0x296FF9FFu,0x96FA4054u));
	A(uvec4(0x3E14FFFFu,0x92D900A5u,0x8677BFFFu,0x92FA10F9u));
	A(uvec4(0x8698993Fu,0x96FAA06Au,0x3E5607A4u,0x8EB85B66u));
	A(uvec4(0x3E56F8FAu,0x8EBA4490u,0x8EBAC040u,0x96FBD0C0u));
	A(uvec4(0x96FB9930u,0x9F1C28AFu,0x35F54B03u,0x9B1C0E4Au));
	A(uvec4(0x3A16E4E4u,0x9AFCD5E5u,0xA35CF4F4u,0xAF9F78B8u));
	A(uvec4(0x92DC1B1Bu,0xAB7E0606u,0x2DB41B5Bu,0x8A9A1B1Bu));
	A(uvec4(0x14EC1B5Bu,0x29930606u,0x14EBD091u,0x212EE4D4u));
	A(uvec4(0x1D0DEAD4u,0x254F6ABFu,0x256FE9D5u,0x299100E4u));
	A(uvec4(0x2991D1E1u,0x2DB26C40u,0x29B3E5EAu,0x35F49EE4u));
	A(uvec4(0x35F3EAF5u,0x3A1600A5u,0x31D3AAFFu,0x3A160056u));
	A(uvec4(0x2D926FAFu,0x35F5005Au,0x257057ABu,0x2DB30006u));
	A(uvec4(0x212E6B6Fu,0x2991051Au,0x190A5B5Fu,0x212D1656u));
	A(uvec4(0x1CEA5656u,0x18EB1B56u,0x1D0AF9F4u,0x2949FDF9u));
	A(uvec4(0x25286F1Au,0x2D49FFBFu,0x25075601u,0x2949BF6Bu));
	A(uvec4(0x21075615u,0x2528BFABu,0x1CE75A05u,0x2507AF5Au));
	A(uvec4(0x20E7A500u,0x2107FFFEu,0x1CE7BF15u,0x2107FFFFu));
	A(uvec4(0x14A4A5E9u,0x1CC64540u,0x1083AAFEu,0x1CE70555u));
	A(uvec4(0xC83566Bu,0x1D070015u,0xC62479Bu,0x10840107u));
	A(uvec4(0xC63E4F5u,0x14A5E4E4u,0x14C6E0E0u,0x8E98E4E4u));
	A(uvec4(0x86791F2Fu,0x96DC0B0Bu,0x8238D480u,0x8EB9FAE5u));
	A(uvec4(0x92F950E4u,0xA33A9490u,0x10A78FCFu,0x9AF9978Fu));
	A(uvec4(0x298D0207u,0x8AB56F15u,0x1D4C00F8u,0xA33C0501u));
	A(uvec4(0xCA7F5E7u,0x96FAA4F4u,0x39F25AABu,0x96FA0001u));
	A(uvec4(0x31F39197u,0x8256E0E0u,0x212D0B42u,0x8256FF7Fu));
	A(uvec4(0x256D81E9u,0x35F21704u,0x296EFDFEu,0x8A7780F8u));
	A(uvec4(0x3E1429E9u,0x86750906u,0x35F3BEBFu,0x867700D5u));
	A(uvec4(0x3E356F54u,0x8277085Bu,0x3E35E5FEu,0x8EB94090u));
	A(uvec4(0x8E993A7Eu,0x9AFB1019u,0x31D22A1Fu,0x8EBA3F3Fu));
	A(uvec4(0x3A37C1D5u,0x92BC88C9u,0xA75C7838u,0xAF9E1869u));
	A(uvec4(0x86796F6Fu,0x9AFC071Bu,0x25712F6Fu,0x82581B1Bu));
	A(uvec4(0x10A95B6Bu,0x1D2F0617u,0xCA9E6F9u,0x1D0D90E4u));
	A(uvec4(0xCA8FFFFu,0x1D2D931Fu,0x14C901BFu,0x254EE5E4u));
	A(uvec4(0x18EB4000u,0x2DB1FFFAu,0x14EA0195u,0x31D2FFAFu));
	A(uvec4(0x10EA40FFu,0x2DB1FF1Bu,0xCA9FEFFu,0x29901B90u));
	A(uvec4(0x10A9FFFFu,0x214EA0EFu,0x18EBBFFFu,0x214F115Au));
	A(uvec4(0x18EBAABFu,0x1D2E0055u,0x18EB6AABu,0x1D0B105Au));
	A(uvec4(0x18EAD0D5u,0x1CEA54D0u,0x1CE9FEFEu,0x294AF8F9u));
	A(uvec4(0x2D6A0000u,0x2D4B0300u,0x29296B1Au,0x2D4A6B6Bu));
	A(uvec4(0x25280606u,0x29291B07u,0x21075F1Bu,0x2528BF6Fu));
	A(uvec4(0xFFFFu,0x2508FFFFu,0x25076A15u,0x2528FFFFu));
	A(uvec4(0x14A41605u,0x2107FF6Au,0xC630505u,0x1CE62F0Au));
	A(uvec4(0x441F9FFu,0xC63E0E8u,0xC626900u,0x1063FEEAu));
	A(uvec4(0xC6390E4u,0x10845B96u,0x14C7F4F4u,0x8EB8F8F8u));
	A(uvec4(0x869A5606u,0xA31CE69Au,0x92D96940u,0xA33C6F6Eu));
	A(uvec4(0x2D8C7FFFu,0x9F1A0B1Fu,0x212985C3u,0x8A73150Au));
	A(uvec4(0x31F0022Fu,0x92D75806u,0x258E0015u,0x3E561F15u));
	A(uvec4(0x14E9E1A0u,0x9F5C5595u,0x82340B09u,0x92D8E450u));
	A(uvec4(0x3614E590u,0x92D8FFFEu,0x86775A50u,0x92D91B0Au));
	A(uvec4(0x2D8FBF07u,0x8677FFBFu,0x18E90605u,0x86566B0Bu));
	A(uvec4(0x10A790FAu,0x31D20000u,0x14C9AFEFu,0x2DB1A0F8u));
	A(uvec4(0x2970E8FAu,0x3A150040u,0x2990FFFFu,0x3E35E4E9u));
	A(uvec4(0x8677E4A4u,0x92FA9494u,0x14E95BBFu,0x92DA4743u));
	A(uvec4(0x1950E8EDu,0x869AE8D8u,0x9AFB3E7Eu,0xAB7D0B2Fu));
	A(uvec4(0x82581A1Bu,0x92DB070Au,0x14EC6F6Fu,0x35F51B1Bu));
	A(uvec4(0xCA8071Bu,0x14EB4042u,0xCA840A0u,0x1D0BB4D1u));
	A(uvec4(0xCA95B64u,0x1D2C5B9Bu,0x18EBE4E4u,0x256FE4E4u));
	A(uvec4(0x257094F9u,0x31B3A554u,0x2991BAFFu,0x31B31559u));
	A(uvec4(0x256F7F6Fu,0x2DB2066Fu,0x1D2D5B7Fu,0x256F071Bu));
	A(uvec4(0xCA8FF0Bu,0x1D2CEFFFu,0x10A84055u,0x214DBA0Bu));
	A(uvec4(0xCA8AAFAu,0x18EB5455u,0x14EAFFFFu,0x18EB4D1Du));
	A(uvec4(0x14C9BFBFu,0x18EA4B5Fu,0x14C9E4F9u,0x252A9094u));
	A(uvec4(0x212AFAFFu,0x2D4AE4F9u,0x29492F2Fu,0x2D4A1F2Fu));
	A(uvec4(0x25282B1Au,0x2949461Au,0x25280D0Du,0x2528070Fu));
	A(uvec4(0x2528E494u,0x2929F4A4u,0x25285B16u,0x2929FFBFu));
	A(uvec4(0x2107A954u,0x316BFEFEu,0x14A52B1Au,0x29496F6Fu));
	A(uvec4(0x421F7F6u,0xC63F3F7u,0xC63F7D7u,0x1063DCFCu));
	A(uvec4(0xC630000u,0x214CC040u,0x212BF8F4u,0x92DAFEF9u));
	A(uvec4(0x92DAE4E4u,0x9F3CAAF9u,0x318CFFFFu,0x9F1A1F7Fu));
	A(uvec4(0x294A020Bu,0x9F3A0000u,0x25284000u,0x296FE950u));
	A(uvec4(0x1D2CB4F4u,0x3E560558u,0x214E0106u,0x92D9F990u));
	A(uvec4(0x214DFD64u,0x96FAFFFFu,0x3A14F9FDu,0x9AFAABE2u));
	A(uvec4(0x92B993A5u,0x9AFB5D8Bu,0x86776F1Bu,0x96FAFEAFu));
	A(uvec4(0x82556BF6u,0x8A980B5Bu,0x31D21A1Bu,0x86770615u));
	A(uvec4(0x14C8AF07u,0x2990ABAFu,0x10A8AAD0u,0x212CFFFFu));
	A(uvec4(0x14C9A4FDu,0x296FEAFEu,0x298FD0E4u,0x3E35E0E5u));
	A(uvec4(0x3A14E5EFu,0x8A9850A0u,0x18EA5F07u,0x8A987F7Fu));
	A(uvec4(0x1D2FE4D4u,0x9B3DE4E4u,0x9AFB172Bu,0xAB7C0257u));
	A(uvec4(0x35F51B6Bu,0x96DA161Bu,0xCA91B2Fu,0x2DB3070Bu));
	A(uvec4(0xCA74410u,0x1D0A60C0u,0xC86FBDDu,0x1CEBA4F5u));
	A(uvec4(0x14C95B6Bu,0x1D2C1459u,0x18EAE4E4u,0x256FA494u));
	A(uvec4(0x214F95FEu,0x2DB1A850u,0x25701AFFu,0x29916905u));
	A(uvec4(0x214F0A1Bu,0x25900A05u,0x1D2D560Bu,0x214E1B56u));
	A(uvec4(0x190B5626u,0x1D2D6FAFu,0x14EA45C6u,0x212D5565u));
	A(uvec4(0x14EA0D02u,0x2DB0D434u,0x14C96A52u,0x1D0BAEACu));
	A(uvec4(0x14C9030Bu,0x18EA0303u,0x14A9D0E5u,0x18E954A0u));
	A(uvec4(0x18E9F4F9u,0x294AA0E4u,0x25285AABu,0x2D4A165Au));
	A(uvec4(0x25285797u,0x29280041u,0x21076FBFu,0x25285F0Fu));
	A(uvec4(0x2528A4A4u,0x2929F4E4u,0x2929BE54u,0x2949FFFFu));
	A(uvec4(0x2D6ABCBCu,0x358CF8FCu,0x20E71F1Bu,0x2D6B2F1Fu));
	A(uvec4(0x8418393u,0x14844343u,0xC63EAEEu,0x1064105Au));
	A(uvec4(0xC85D080u,0x92D9F8F4u,0x92B8FEF8u,0x9B1C2FBFu));
	A(uvec4(0x3DEFFFFFu,0x9AFB16ABu,0x2949070Fu,0x92B60102u));
	A(uvec4(0x18E86AE7u,0x294A8565u,0x212B68E4u,0x31D1F958u));
	A(uvec4(0x214EE440u,0x9F3CFEF9u,0x8E98AAA4u,0xA33CFFAFu));
	A(uvec4(0x9F1C6404u,0xAB7CBE69u,0x92DAAA16u,0xA35CAFABu));
	A(uvec4(0x3E350FFAu,0x96FBFF3Fu,0x2D90FFFFu,0x96FA1B99u));
	A(uvec4(0x31B1BFBFu,0x8A77D0FFu,0x31D2060Au,0x86565B05u));
	A(uvec4(0x1D0C5B1Bu,0x2DB1AF5Bu,0x1D0C2854u,0x2970FBB6u));
	A(uvec4(0x1D0CF9FFu,0x254EBAA4u,0x212DA9F9u,0x2DB15094u));
	A(uvec4(0x2DB0FDF9u,0x3A1490F8u,0x212E7FBFu,0x8256FE3Bu));
	A(uvec4(0x2591E4E4u,0x9B3C0094u,0x35F46FBFu,0x96FA0056u));
	A(uvec4(0x29906F6Fu,0x82570A1Bu,0xCA8070Bu,0x214F4182u));
	A(uvec4(0x4445E29u,0x14E9AF9Bu,0x10A796D8u,0x14C98054u));
	A(uvec4(0xCA7E4A5u,0x1D0BF9E5u,0x1D0BE490u,0x2DB0E9F9u));
	A(uvec4(0x298FA968u,0x31F2BEFEu,0x256F1A6Au,0x2DD1FF1Bu));
	A(uvec4(0x256F9055u,0x29B02F00u,0x1D2D1F1Fu,0x256F415Bu));
	A(uvec4(0x1D0C1A45u,0x214E060Fu,0x190B0411u,0x212CE4D0u));
	A(uvec4(0x190B39D0u,0x298E9596u,0x18EA0F03u,0x3A120D0Du));
	A(uvec4(0x14A90202u,0x18EAA743u,0x14C95528u,0x14CADF5Au));
	A(uvec4(0x14C9F0F4u,0x2109A5E0u,0x2107ABAFu,0x25295056u));
	A(uvec4(0x2507F6F2u,0x2528A1F5u,0xFFFFu,0x2508FFFFu));
	A(uvec4(0x2528FEFCu,0x2949FCFDu,0xFFFFu,0x2949FFFFu));
	A(uvec4(0x2949F8FDu,0x318B0054u,0x14A56F6Fu,0x2D4A1A1Bu));
	A(uvec4(0x4215747u,0x10639757u,0x4420000u,0x3612D080u));
	A(uvec4(0x254BFDF8u,0x9AFBBFFEu,0x31B11BBFu,0x96DA0106u));
	A(uvec4(0x318C191Bu,0x39F31A29u,0x21280102u,0x39EFFA11u));
	A(uvec4(0x1D085440u,0x8A95FFADu,0x31D1F9E0u,0x9B1AFFFEu));
	A(uvec4(0x96FAF9F4u,0xA75CFEFDu,0xA35CD743u,0xA75C0195u));
	A(uvec4(0xA75CFDBDu,0xAB7DFCFDu,0x9F1C1B06u,0xAB7D551Au));
	A(uvec4(0x96FB0A06u,0x9F3CAF1Bu,0x96DAD1B4u,0x9F3C1A45u));
	A(uvec4(0x256EBF06u,0x9F3CFFFFu,0x256F4154u,0x9AFCFFAFu));
	A(uvec4(0x190C5656u,0x8E99BF06u,0x190CFFAAu,0x39F406A4u));
	A(uvec4(0x14ECEFAAu,0x31B250FFu,0x256F6A00u,0x31B200FFu));
	A(uvec4(0x10A9FBFFu,0x2D901AFFu,0x14CAD79Eu,0x3E3658A1u));
	A(uvec4(0x10CB1606u,0x8A99E9A9u,0xCA90094u,0x8EBABF1Au));
	A(uvec4(0x86769BFu,0x29911700u,0x465DB9Bu,0x18E9E1D0u));
	A(uvec4(0x10A79717u,0x14C984C4u,0x14C8A540u,0x252CE0F9u));
	A(uvec4(0x1D0BD0D0u,0x296D8190u,0x296EF8F8u,0x35D1E0F8u));
	A(uvec4(0x31D1EA69u,0x3E340046u,0x216E6F06u,0x35F2FEBFu));
	A(uvec4(0x214DA5FDu,0x29B06B06u,0x214DBF06u,0x2DB00000u));
	A(uvec4(0x1D2B6F9Au,0x296E0105u,0x18EAA65Bu,0x214D9145u));
	A(uvec4(0x1D2BF9E4u,0x256EFEADu,0x14E91D1Du,0x31B02929u));
	A(uvec4(0x10A96FABu,0x18E90717u,0x10C9A996u,0x14EAF8F8u));
	A(uvec4(0x1CE81B15u,0x18EA1F1Fu,0xFFFFu,0x2107FFFFu));
	A(uvec4(0x21074057u,0x25070000u,0x2107D5D5u,0x25085455u));
	A(uvec4(0x2528F8FDu,0x2929A4E4u,0x2528BFFFu,0x2929166Fu));
	A(uvec4(0x1CE769BEu,0x25290015u,0x14A41B2Fu,0x2107061Bu));
	A(uvec4(0x8414B87u,0xC63EF6Bu,0x864F4E0u,0x8697FDF8u));
	A(uvec4(0x256F1B6Fu,0x8EBA0107u,0x31B1F854u,0x8A75FCFCu));
	A(uvec4(0x31AE0606u,0x92D7E491u,0x2D8CF490u,0x9F39FFFEu));
	A(uvec4(0x8EB6D590u,0x9F3BFFFAu,0x9B1AC1C0u,0xA35CE5D6u));
	A(uvec4(0xA35C455Fu,0xA75C9409u,0xA33C9155u,0xA75CE5D1u));
	A(uvec4(0xA75C00F4u,0xAB7D0100u,0xA33C6F17u,0xA75C9AA6u));
	A(uvec4(0x9F1C1905u,0xA35C6B1Au,0x9AFB1400u,0x9F3C5745u));
	A(uvec4(0x96DA91BAu,0x9F1C4102u,0x92DAA670u,0x9AFC6116u));
	A(uvec4(0x8A792F2Fu,0x92DB9BABu,0x39F4FF2Fu,0x8A9ABFBFu));
	A(uvec4(0x10AAAF06u,0x3E37FFFFu,0x14CA5500u,0x3E36FFBFu));
	A(uvec4(0x1D0C5400u,0x8238AF25u,0x18EBBDAAu,0x299007AEu));
	A(uvec4(0x190CE4F9u,0x8257D0E0u,0x2D926F7Fu,0x86781A1Bu));
	A(uvec4(0x1D0C071Bu,0x29B20516u,0x14C90000u,0x8675D050u));
	A(uvec4(0xC861519u,0x18E9EBEAu,0x10A7F4E4u,0x254D56F5u));
	A(uvec4(0x18E9FFDBu,0x254D14EBu,0x1D2BAAA6u,0x2D9000FAu));
	A(uvec4(0x256E56FAu,0x2D901407u,0x214D51FEu,0x31D11400u));
	A(uvec4(0x1D2C5FAFu,0x298F5078u,0x190A0F56u,0x254D1A6Eu));
	A(uvec4(0x190A808Bu,0x214CB4FAu,0x14EAD6E6u,0x254DE091u));
	A(uvec4(0x212C0A7Fu,0x298F6505u,0x14C82D2Eu,0x256E1A1Eu));
	A(uvec4(0x10A91F1Fu,0x14C97F6Fu,0x10A9F8FDu,0x14EAE9F8u));
	A(uvec4(0x18E91F0Fu,0x14EA0B1Fu,0x1CE85495u,0x2508FDA5u));
	A(uvec4(0xFFFFu,0x2107FFFFu,0x210794A5u,0x2507FA94u));
	A(uvec4(0x2508F0FCu,0x2528F0F0u,0x25081FFFu,0x2528FFFFu));
	A(uvec4(0xC63AAFFu,0x1CC60055u,0xC635B6Fu,0x14A50016u));
	A(uvec4(0xC639040u,0x1D08E4E4u,0x296CB8FCu,0x82561464u));
	A(uvec4(0x214D4102u,0x3E33D0D0u,0x3A12BC7Cu,0x92D7FEFEu));
	A(uvec4(0x3E32FDE8u,0x9B19FFFFu,0x9F3A99A8u,0xA35BF7E9u));
	A(uvec4(0xA33B0C08u,0xA75C0104u,0x9F3B86C1u,0xA35CE0D6u));
	A(uvec4(0xA35CA0E4u,0xA77CA5A0u,0xA35CF556u,0xA75C47F5u));
	A(uvec4(0xA75C1101u,0xA77D0D55u,0xA75C5D1Cu,0xA77D5C47u));
	A(uvec4(0xA33C170Au,0xA75CEF17u,0x9B1C2915u,0xA75C5B56u));
	A(uvec4(0x96FB1900u,0x9F1CEA6Au,0x92DB5500u,0x9F1C6F59u));
	A(uvec4(0x8A9A5702u,0x96DBBFAFu,0x82581B7Fu,0x8EBA5F1Fu));
	A(uvec4(0x3E37E990u,0x8EBAFFFEu,0x3E371601u,0x8A9A5B6Bu));
	A(uvec4(0x3A174A56u,0x86782B26u,0x14EC1B1Bu,0x35F5AB5Bu));
	A(uvec4(0x14EBBD00u,0x35F5FFFFu,0x14EA0169u,0x31F46F2Fu));
	A(uvec4(0xCA755AFu,0x1D2DA601u,0x10A700C0u,0x31B00100u));
	A(uvec4(0x14C75543u,0x296D0040u,0x14C82E06u,0x31AEA569u));
	A(uvec4(0x14C61E2Eu,0x2D8F0205u,0x10A5955Au,0x2549074Bu));
	A(uvec4(0x14C596E5u,0x212C64A9u,0x18E9AABFu,0x256E0555u));
	A(uvec4(0x14C94BEBu,0x1D2C1005u,0x14E96A1Bu,0x214C1555u));
	A(uvec4(0x14E9AAFCu,0x1D2BA4A5u,0x190AFEF4u,0x212C45FEu));
	A(uvec4(0x14E906AFu,0x1D2D561Bu,0x10A74E5Eu,0x212C4B4Eu));
	A(uvec4(0x14C97916u,0x18E9FFBEu,0xCA7EAFAu,0x14CA8296u));
	A(uvec4(0x14C9D1D6u,0x18E9F8D0u,0x1CE9FCFCu,0x2528F9FCu));
	A(uvec4(0x21087F17u,0x2528FFFFu,0x2507FFC0u,0x2508FFFFu));
	A(uvec4(0x2107FFFFu,0x25081F7Fu,0x2107FFFFu,0x250840E5u));
	A(uvec4(0x84355FBu,0xC634669u,0x842BDFFu,0xC431669u));
	A(uvec4(0xC63E0E4u,0x1D0890D0u,0x2129A565u,0x3E11E4E4u));
	A(uvec4(0x296DF9E0u,0x8A94FFFEu,0x8EB5E4E4u,0x9B19F4F4u));
	A(uvec4(0x9F19C090u,0xA75BC0C1u,0xA33AA691u,0xAB7CF4A5u));
	A(uvec4(0xA33A5151u,0xA75CB965u,0x9F3BE0E0u,0xA75CB9F4u));
	A(uvec4(0xA35C4FD7u,0xA75CF7FFu,0xA35C9556u,0xAB7D4346u));
	A(uvec4(0xA75C410Du,0xA77D4409u,0xA75C9559u,0xAB7DB054u));
	A(uvec4(0xA75C0601u,0xAB7E7E7Fu,0xA33C5905u,0xAB7D55E9u));
	A(uvec4(0x9F1C5E44u,0xA75DE6BBu,0x9F1C4100u,0xA75D2F02u));
	A(uvec4(0x96DB1A15u,0xA33C2E6Fu,0x8A995E09u,0x96FBFFEFu));
	A(uvec4(0x8EBA5F2Fu,0x96FB1AAFu,0x82575B47u,0x8A997A56u));
	A(uvec4(0x3E371A06u,0x8EBA1E2Eu,0x2992E6D1u,0x3A16BFBFu));
	A(uvec4(0x2DB467BFu,0x35F5D2CAu,0x214F1B1Bu,0x35F56F5Bu));
	A(uvec4(0x1D0DF490u,0x2DB2FEF9u,0x1D0B5B06u,0x31B2FFBFu));
	A(uvec4(0xC865B15u,0x254EBFAFu,0xC8641F4u,0x1D0A6E2Au));
	A(uvec4(0x10A62E0Bu,0x212B01E4u,0xC85000Bu,0x254BF96Bu));
	A(uvec4(0x14A60054u,0x214CAF00u,0x10A719BEu,0x1D0AAA54u));
	A(uvec4(0x10C8A85Eu,0x18E96FFEu,0xCA786A6u,0x18EAFEE1u));
	A(uvec4(0x14E9FE50u,0x1D0BBFFFu,0x190A1600u,0x212C2D7Eu));
	A(uvec4(0x14E94A5Au,0x212BD559u,0xC85A79Bu,0x1D0B43A7u));
	A(uvec4(0x14E92515u,0x1D0A3928u,0x86592E7u,0x10A88182u));
	A(uvec4(0x10A8F9F9u,0x1CE9F8F8u,0x25281A55u,0x2529FF5Fu));
	A(uvec4(0xFFFFu,0x2528FFFFu,0xFFFFu,0x2508FFFFu));
	A(uvec4(0x20E7055Au,0x25085F05u,0x20E7F5FFu,0x2107D150u));
	A(uvec4(0xC630000u,0xC635B01u,0x8421615u,0xC63BF5Au));
	A(uvec4(0x44290E4u,0xC840501u,0x10A5E4E4u,0x3E1190E0u));
	A(uvec4(0x3A10FFFFu,0x8A94F8FEu,0x8A94F9F9u,0x9AF8E4F9u));
	A(uvec4(0x9B19F0D0u,0xA75B24B0u,0xA33AB8B4u,0xAB7CFDBCu));
	A(uvec4(0xA33B1B1Au,0xAB7C060Bu,0x9F3BF8B8u,0xA75CFBFAu));
	A(uvec4(0xA35CD2DBu,0xA75CBFF3u,0xA35CB1E7u,0xA75C6D79u));
	A(uvec4(0xA75CE040u,0xAB7DF690u,0xA75CE9F9u,0xAB7DF1EAu));
	A(uvec4(0xAB5C7D25u,0xAB7D6BBFu,0xA75C6950u,0xAB7D0A1Bu));
	A(uvec4(0xA35C9B86u,0xA75C9AEAu,0xA33C0A1Eu,0xA75D0005u));
	A(uvec4(0x96FA7F2Fu,0xA33C6F6Fu,0x92DAE994u,0x9AFC1E5Au));
	A(uvec4(0x8A990B5Bu,0x96FB0A0Au,0x8679EA7Au,0x8A9A0F9Fu));
	A(uvec4(0x3E380B2Fu,0x8A99161Bu,0x35F51A1Au,0x3E581E1Eu));
	A(uvec4(0x31D48141u,0x3E37F090u,0x2DB31B16u,0x3E37BF6Fu));
	A(uvec4(0x29922560u,0x35F56F1Au,0x2DB22D28u,0x35F4001Cu));
	A(uvec4(0x1D2C6F0Bu,0x2DB1AFBFu,0x14E95A05u,0x214D7F5Fu));
	A(uvec4(0x14C75A10u,0x1D0BFF99u,0xCA7AA40u,0x1D0BFFFFu));
	A(uvec4(0x10C840F9u,0x256D1616u,0xCA7FFFFu,0x212C1540u));
	A(uvec4(0xCA7FFFFu,0x1D0B40FEu,0x14C8AAFFu,0x1D2B5456u));
	A(uvec4(0x18E995EBu,0x1D0B4000u,0x14E961B0u,0x1D0AE740u));
	A(uvec4(0xCA7B9E5u,0x296D411Eu,0x8640001u,0x14C85F01u));
	A(uvec4(0xC8664BDu,0x1D092161u,0x46596E2u,0xC879595u));
	A(uvec4(0x1087E4E4u,0x2109E0E4u,0x2129FDF8u,0x2529FEFDu));
	A(uvec4(0x25285500u,0x2929BEA9u,0x25280100u,0x25285705u));
	A(uvec4(0x25087F05u,0x2528FFFFu,0x20E71705u,0x25086F1Fu));
	A(uvec4(0xC635A15u,0x1484FFAFu,0xC635500u,0x1084BFABu));
	A(uvec4(0xC630000u,0x1063FF86u,0xC63E4F4u,0x214A5090u));
	A(uvec4(0x18E8E5FAu,0x82734094u,0x2DAEFEFEu,0x8EB6A4E9u));
	A(uvec4(0x8A96FEFEu,0x9F1AE4F8u,0x9F3AAAEAu,0xAB7C5196u));
	A(uvec4(0xA35B5441u,0xA77C5B5Eu,0xA35C5559u,0xA75C96D1u));
	A(uvec4(0xA75C6414u,0xAB7CC4D5u,0xA75C9004u,0xAB7D92F0u));
	A(uvec4(0xA75C5DFBu,0xAB7D2D78u,0xA75CFEE2u,0xAB7D28E8u));
	A(uvec4(0xA75C666Au,0xAF9D6875u,0xAB5C6516u,0xAB7D5D54u));
	A(uvec4(0xA33C7F7Fu,0xA75C2E07u,0x9F1C066Au,0xA33C2F2Eu));
	A(uvec4(0x9AFB1E1Fu,0x9F3C2E2Au,0x92DA0419u,0x9B1C0B05u));
	A(uvec4(0x8A9A9B4Bu,0x92DA9B8Bu,0x8679070Bu,0x8EBA9643u));
	A(uvec4(0x361647AFu,0x82581707u,0x35F51A1Au,0x8258E4A5u));
	A(uvec4(0x35F5F9F4u,0x8258FEFEu,0x3A161A1Au,0x8258AF5Fu));
	A(uvec4(0x2DB33F2Fu,0x3A165F2Fu,0x29922E1Au,0x31D47F6Fu));
	A(uvec4(0x25700A1Au,0x2DB35B0Bu,0x214E4100u,0x2DB1D686u));
	A(uvec4(0x214D5F06u,0x2990FFBFu,0x1D2B0605u,0x256FAB5Au));
	A(uvec4(0x14E96B1Bu,0x1D2B2BBFu,0x14E95550u,0x190AF8F5u));
	A(uvec4(0x10A7AA06u,0x190AFFFFu,0xC86AF00u,0x14E9FFFFu));
	A(uvec4(0xC86EA15u,0x14C8BFFFu,0xC87FA00u,0x14C9FEFEu));
	A(uvec4(0x10A87FFCu,0x14C9FFFFu,0xC650B1Fu,0x14C80F0Bu));
	A(uvec4(0x8647CB8u,0x14A7AD6Du,0x8669540u,0xC87EF9Au));
	A(uvec4(0x10A8E0E0u,0x2109E4E4u,0x2529E4B4u,0x294890E4u));
	A(uvec4(0xFFFFu,0x2929FFFFu,0x25281F07u,0x2929571Fu));
	A(uvec4(0x25285A0Au,0x29291F55u,0x21077F2Fu,0x25287FBFu));
	A(uvec4(0x1084D5D1u,0x14A4FDFDu,0x14A40500u,0x18A57F18u));
	A(uvec4(0x1084AA41u,0x14A5FFFEu,0x10840100u,0x18A57F06u));
	A(uvec4(0xC8490E5u,0x18E90040u,0x14C7E5F9u,0x35F04090u));
	A(uvec4(0x256CF9FEu,0x8EB790E4u,0x8A75FEFFu,0x9F3AF4F9u));
	A(uvec4(0xA33B2E66u,0xA77C152Au,0xA35C60A5u,0xA77CE0A0u));
	A(uvec4(0xA75C9180u,0xAB7DE9D5u,0xA75CFAA1u,0xAB7D6EBFu));
	A(uvec4(0xA75C5E1Eu,0xAB7D59A9u,0xA75C9755u,0xAB7D1B5Bu));
	A(uvec4(0xA35CAAEEu,0xAB7D4055u,0xA33C666Fu,0xAB7D0641u));
    //-------------------------------------------------------------------------
	C = col + texelFetch(iChannel0,SV_DispatchThreadID,0);
    
}