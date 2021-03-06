# 批量更新企业的VOS前缀
# You can run this seed by `$ rake db:seed:update_vos_prefix_from_array`
puts "批量更新企业的VOS前缀开始"
prefix_array = [
  ['60003','a011','a012','a011'],
  ['60019','a011','a012','a011'],
  ['60033','d031','d032','d031'],
  ['60034','a011','a012','a011'],
  ['60039','a061','a062','a061'],
  ['60042','a501','a502','a501'],
  ['60049','a041','a042','a041'],
  ['60053','a011','a012','a011'],
  ['60057','d011','d012','d011'],
  ['60061','a011','a012','a011'],
  ['60062','a011','a012','a011'],
  ['60065','a011','a012','a011'],
  ['60066','a011','a012','a011'],
  ['60068','a501','a502','a501'],
  ['60073','a011','a012','a011'],
  ['60075','a011','a012','a011'],
  ['60077','a011','a012','a011'],
  ['60079','a011','a012','a011'],
  ['60084','e991','e992','e991'],
  ['60088','a281','a282','a281'],
  ['60090','a051','a052','a051'],
  ['60092','a011','a012','a011'],
  ['60101','a011','a012','a011'],
  ['60102','e501','e502','e501'],
  ['60107','a051','a052','a051'],
  ['60108','e051','e052','e051'],
  ['60117','a011','a012','a011'],
  ['60125','a011','a012','a011'],
  ['60126','a011','a012','a011'],
  ['60127','a011','a012','a011'],
  ['60128','a011','a012','a011'],
  ['60129','a011','a012','a011'],
  ['60130','a011','a012','a011'],
  ['60131','a011','a012','a011'],
  ['60133','e041','e042','e041'],
  ['60137','a011','a012','a011'],
  ['60138','a011','a012','a011'],
  ['60143','a501','a502','a501'],
  ['60145','a281','a282','a281'],
  ['60146','a381','a382','a381'],
  ['60153','a011','a012','a011'],
  ['60156','d041','d042','d041'],
  ['60157','a051','a052','a051'],
  ['60160','d041','d042','d041'],
  ['60161','a501','a502','a501'],
  ['60164','a501','a502','a501'],
  ['60165','a011','a012','a011'],
  ['60166','a501','a502','a501'],
  ['60167','a501','a502','a501'],
  ['60173','a011','a012','a011'],
  ['60175','e061','e062','e061'],
  ['60176','f501','f502','f501'],
  ['60188','a041','a042','a041'],
  ['60192','d041','d042','d041'],
  ['60199','a041','a042','a041'],
  ['60200','a081','a082','a081'],
  ['60201','a011','a012','a011'],
  ['60212','b051','b052','b051'],
  ['60214','d011','d012','d011'],
  ['60216','d281','d282','d281'],
  ['60217','a381','a382','a381'],
  ['60218','a381','a382','a381'],
  ['60219','a381','a382','a381'],
  ['60221','a281','a282','a281'],
  ['60222','a011','a012','a011'],
  ['60223','a381','a382','a381'],
  ['60224','a381','a382','a381'],
  ['60225','a021','a022','a021'],
  ['60226','a381','a382','a381'],
  ['60227','d061','d062','d061'],
  ['60228','a031','a032','a031'],
  ['60232','d051','d052','d051'],
  ['60287','d151','d152','d151'],
  ['60295','f501','f502','f501'],
  ['60297','a011','a012','a011'],
  ['60301','a441','a442','a441'],
  ['60302','a011','a012','a011'],
  ['60303','e051','e052','e051'],
  ['60306','a011','a012','a011'],
  ['60310','d051','d052','d051'],
  ['60311','a041','a042','a041'],
  ['60318','a031','a032','a031'],
  ['60322','d021','d022','d021'],
  ['60323','a051','a052','a051'],
  ['60325','a051','a052','a051'],
  ['60327','e051','e052','e051'],
  ['60330','a881','a882','a881'],
  ['60331','f051','f052','f051'],
  ['60332','a011','a012','a011'],
  ['60336','a581','a582','a581'],
  ['60340','d011','d012','d011'],
  ['60341','a011','a012','a011'],
  ['60347','d041','d042','d041'],
  ['60348','a061','a062','a061'],
  ['60349','a051','a052','a051'],
  ['60350','a051','a052','a051'],
  ['60714','a021','a022','a021'],
  ['60719','a281','a282','a281'],
  ['60720','d031','d032','d031'],
  ['60721','d061','d062','d061'],
  ['60722','a381','a382','a381'],
  ['60723','d331','d332','d331'],
  ['60724','a331','a332','a331'],
  ['60725','d041','d042','d041'],
  ['60726','a331','a332','a331'],
  ['60728','a181','a182','a181'],
  ['60730','d061','d062','d061'],
  ['60731','a011','a012','a011'],
  ['60732','d041','d042','d041'],
  ['60733','a381','a382','a381'],
  ['60734','a331','a332','a331'],
  ['60735','a331','a332','a331'],
  ['60736','d381','d382','d381'],
  ['60737','a181','a182','a181'],
  ['60738','a381','a382','a381'],
  ['60739','d041','d042','d041'],
  ['60742','a381','a382','a381'],
  ['60743','d051','d052','d051'],
  ['60744','d041','d042','d041'],
  ['60748','d041','d042','d041'],
  ['60750','a051','a052','a051'],
  ['60752','d281','d282','d281'],
  ['60753','d051','d052','d051'],
  ['60754','e071','e072','e071'],
  ['60756','d381','d382','d381'],
  ['60761','a281','a282','a281'],
  ['60763','a021','a022','a021'],
  ['60764','a281','a282','a281'],
  ['60767','a021','a022','a021'],
  ['60768','a021','a022','a021'],
  ['60772','a381','a382','a381'],
  ['60774','a151','a152','a151'],
  ['60775','e071','e072','e071'],
  ['60776','a061','a062','a061'],
  ['60777','a011','a012','a011'],
  ['60779','d331','d332','d331'],
  ['60780','d051','d052','d051'],
  ['60781','d181','d182','d181'],
  ['60783','d061','d062','d061'],
  ['60784','a281','a282','a281'],
  ['60786','d041','d042','d041'],
  ['60787','d181','d182','d181'],
  ['60789','a041','a042','a041'],
  ['60790','d051','d052','d051'],
  ['60792','a581','a582','a581'],
  ['60794','a281','a282','a281'],
  ['60795','d381','d382','d381'],
  ['60796','a381','a382','a381'],
  ['60798','d041','d042','d041'],
  ['60803','a011','a012','a011'],
  ['60804','d331','d332','d331'],
  ['61028','e181','e182','e181'],
  ['61029','b881','b882','b881'],
  ['61032','e181','e182','e181'],
  ['61503','d051','d052','d051'],
  ['61509','c051','c052','c051'],
  ['61510','d041','d042','d041'],
  ['61513','d281','d282','d281'],
  ['61515','c331','c332','c331'],
  ['61517','d181','d182','d181'],
  ['61518','d331','d332','d331'],
  ['61520','d051','d052','d051'],
  ['61523','d281','d282','d281'],
  ['61524','d051','d052','d051'],
  ['61525','e051','e052','e051'],
  ['61527','d031','d032','d031'],
  ['61530','d281','d282','d281'],
  ['62002','a011','a012','a011'],
  ['62004','a011','a012','a011'],
  ['62005','a751','a752','a751'],
  ['62007','a011','a012','a011'],
  ['62009','d011','d012','d011'],
  ['62014','d061','d062','d061'],
  ['62016','d061','d062','d061'],
  ['62020','e501','e502','e501'],
  ['62022','a011','a012','a011'],
  ['62027','e081','e082','e081'],
  ['62028','d501','d502','d501'],
  ['62030','a011','a012','a011'],
  ['62035','a011','a012','a011'],
  ['62036','a011','a012','a011'],
  ['62040','a011','a012','a011'],
  ['62042','d501','d502','d501'],
  ['62043','a501','a502','a501'],
  ['62046','e041','e042','e041'],
  ['62047','a071','a072','a071'],
  ['62050','a011','a012','a011'],
  ['62051','a011','a012','a011'],
  ['62052','a501','a502','a501'],
  ['62054','a501','a502','a501'],
  ['62058','e071','e072','e071'],
  ['62059','a501','a502','a501'],
  ['62063','e051','e052','e051'],
  ['62067','a011','a012','a011'],
  ['62070','e061','e062','e061'],
  ['62077','e061','e062','e061'],
  ['62080','d061','d062','d061'],
  ['62084','d181','d182','d181'],
  ['62089','e181','e182','e181'],
  ['62090','b151','b152','b151'],
  ['62091','e061','e062','e061'],
  ['62092','e061','e062','e061'],
  ['62093','d181','d182','d181'],
  ['62097','a441','a442','a441'],
  ['62098','d181','d182','d181'],
  ['62099','d501','d502','d501'],
  ['62106','d051','d052','d051'],
  ['62112','d071','d072','d071'],
  ['62114','d581','d582','d581'],
  ['62119','d051','d052','d051'],
  ['62120','a011','a012','a011'],
  ['62121','d041','d042','d041'],
  ['62127','d181','d182','d181'],
  ['62130','d181','d182','d181'],
  ['62131','a281','a282','a281'],
  ['62134','a011','a012','a011'],
  ['62141','a281','a282','a281'],
  ['62146','d071','d072','d071'],
  ['62148','a061','a062','a061'],
  ['62150','a281','a282','a281'],
  ['62154','a281','a282','a281'],
  ['62162','c051','c052','c051'],
  ['62164','d051','d052','d051'],
  ['62165','d071','d072','d071'],
  ['62168','a281','a282','a281'],
  ['62171','a281','a282','a281'],
  ['62173','d061','d062','d061'],
  ['62175','d281','d282','d281'],
  ['62176','d061','d062','d061'],
  ['62177','a281','a282','a281'],
  ['62180','a061','a062','a061'],
  ['62181','d061','d062','d061'],
  ['62183','d051','d052','d051'],
  ['62184','e071','e072','e071'],
  ['62186','d051','d052','d051'],
  ['62191','a281','a282','a281'],
  ['62192','d281','d282','d281'],
  ['62193','d051','d052','d051'],
  ['62195','e051','e052','e051'],
  ['62196','d281','d282','d281'],
  ['62197','a281','a282','a281'],
  ['62198','e061','e062','e061'],
  ['62201','e061','e062','e061'],
  ['62204','d181','d182','d181'],
  ['62205','a381','a382','a381'],
  ['62207','d051','d052','d051'],
  ['62208','a011','a012','a011'],
  ['62212','d381','d382','d381'],
  ['62215','d991','d992','d991'],
  ['62241','d181','d182','d181'],
  ['62244','d181','d182','d181'],
  ['63002','e081','e082','e081'],
  ['63003','f061','f062','f061'],
  ['63004','a501','a502','a501'],
  ['63013','b081','b082','b081'],
  ['63016','d051','d052','d051'],
  ['63017','e051','e052','e051'],
  ['63018','e051','e052','e051'],
  ['63020','d051','d052','d051'],
  ['63021','d051','d052','d051'],
  ['63022','a051','a052','a051'],
  ['63023','a051','a052','a051'],
  ['63024','a051','a052','a051'],
  ['63025','d051','d052','d051'],
  ['63027','d051','d052','d051'],
  ['63030','d051','d052','d051'],
  ['63032','d061','d062','d061'],
  ['63033','d051','d052','d051'],
  ['63039','a051','a052','a051'],
  ['63040','e051','e052','e051'],
  ['63041','e071','e072','e071'],
  ['63042','d281','d282','d281'],
  ['63051','d051','d052','d051'],
  ['63052','d051','d052','d051'],
  ['63054','d051','d052','d051'],
  ['63055','d051','d052','d051'],
  ['63056','e881','e882','e881'],
  ['63060','d051','d052','d051'],
  ['64007','a011','a012','a011'],
  ['64012','a011','a012','a011'],
  ['64013','a011','a012','a011'],
  ['64015','d011','d012','d011'],
  ['64016','c991','c992','c991'],
  ['64021','f501','f502','f501'],
  ['64030','d011','d012','d011'],
  ['64031','d501','d502','d501'],
  ['64046','d021','d022','d021'],
  ['64047','d051','d052','d051'],
  ['64048','a071','a072','a071'],
  ['64050','d031','d032','d031'],
  ['64051','d071','d072','d071'],
  ['64053','a351','a352','a351'],
  ['64054','a501','a502','a501'],
  ['64060','d011','d012','d011'],
  ['64061','a011','a012','a011'],
  ['64065','a011','a012','a011'],
  ['64068','d991','d992','d991'],
  ['64069','a041','a042','a041'],
  ['64071','f061','f062','f061'],
  ['64072','d061','d062','d061'],
  ['64074','f061','f062','f061'],
  ['64076','f501','f502','f501'],
  ['64080','a011','a012','a011'],
  ['64087','f501','f502','f501'],
  ['64090','d061','d062','d061'],
  ['64095','a501','a502','a501'],
  ['64099','a041','a042','a041'],
  ['64101','d041','d042','d041'],
  ['64103','d061','d062','d061'],
  ['64104','d501','d502','d501'],
  ['64113','d051','d052','d051'],
  ['64118','d101','d102','d101'],
  ['64119','a151','a152','a151'],
  ['64122','f051','f052','f051'],
  ['64129','f501','f502','f501'],
  ['64131','d011','d012','d011'],
  ['64133','a011','a012','a011'],
  ['64135','d501','d502','d501'],
  ['64137','d331','d332','d331'],
  ['64138','d041','d042','d041'],
  ['64140','d041','d042','d041'],
  ['64141','d041','d042','d041'],
  ['64145','d051','d052','d051'],
  ['64146','a051','a052','a051'],
  ['64149','a021','a022','a021'],
  ['64150','a281','a282','a281'],
  ['64152','d041','d042','d041'],
  ['64153','a051','a052','a051'],
  ['64154','a051','a052','a051'],
  ['64155','d041','d042','d041'],
  ['64156','d151','d152','d151'],
  ['64157','a011','a012','a011'],
  ['64158','d011','d012','d011'],
  ['64160','d051','d052','d051'],
  ['64161','d031','d032','d031'],
  ['64162','d041','d042','d041'],
  ['64165','a041','a042','a041'],
  ['64167','d041','d042','d041'],
  ['64172','d041','d042','d041'],
  ['64174','d031','d032','d031'],
  ['64175','d011','d012','d011'],
  ['64176','a501','a502','a501'],
  ['64180','d041','d042','d041'],
  ['64182','d031','d032','d031'],
  ['64185','d041','d042','d041'],
  ['64186','d011','d012','d011'],
  ['64188','d041','d042','d041'],
  ['64312','e041','e042','e041'],
  ['65003','a011','a012','a011'],
  ['65008','a011','a012','a011'],
  ['65009','d011','d012','d011'],
  ['65011','a011','a012','a011'],
  ['65016','a151','a152','a151'],
  ['65020','a011','a012','a011'],
  ['65022','a011','a012','a011'],
  ['65023','a011','a012','a011'],
  ['65024','a381','a382','a381'],
  ['65025','a011','a012','a011'],
  ['65026','a011','a012','a011'],
  ['65028','a011','a012','a011'],
  ['65033','a011','a012','a011'],
  ['65036','d051','d052','d051'],
  ['65040','a501','a502','a501'],
  ['65041','a011','a012','a011'],
  ['65046','a011','a012','a011'],
  ['65047','d051','d052','d051'],
  ['65048','e051','e052','e051'],
  ['65056','a051','a052','a051'],
  ['65057','a011','a012','a011'],
  ['65058','a011','a012','a011'],
  ['65060','a021','a022','a021'],
  ['65063','d041','d042','d041'],
  ['65065','a011','a012','a011'],
  ['65066','a011','a012','a011'],
  ['65068','a011','a012','a011'],
  ['65070','a041','a042','a041'],
  ['65071','a011','a012','a011'],
  ['65072','a011','a012','a011'],
  ['65086','a351','a352','a351'],
  ['65087','a501','a502','a501'],
  ['65093','a011','a012','a011'],
  ['65094','a011','a012','a011'],
  ['65096','a101','a102','a101'],
  ['65097','a501','a502','a501'],
  ['65099','b021','b022','b021'],
  ['65103','a381','a382','a381'],
  ['65105','a281','a282','a281'],
  ['65108','d031','d032','d031'],
  ['65110','a031','a032','a031'],
  ['65118','a281','a282','a281'],
  ['65120','a031','a032','a031'],
  ['65121','d041','d042','d041'],
  ['65122','a281','a282','a281'],
  ['65123','a181','a182','a181'],
  ['65124','a381','a382','a381'],
  ['65129','a381','a382','a381'],
  ['65132','a281','a282','a281'],
  ['65135','a381','a382','a381'],
  ['65136','d181','d182','d181'],
  ['65137','a381','a382','a381'],
  ['65141','a281','a282','a281'],
  ['65143','a281','a282','a281'],
  ['65145','a011','a012','a011'],
  ['65146','a281','a282','a281'],
  ['65151','a031','a032','a031'],
  ['65152','a381','a382','a381'],
  ['65154','a061','a062','a061'],
  ['65156','a031','a032','a031'],
  ['65157','d031','d032','d031'],
  ['65158','d051','d052','d051'],
  ['65160','d281','d282','d281'],
  ['65161','d031','d032','d031'],
  ['65163','e181','e182','e181'],
  ['65164','a031','a032','a031'],
  ['65166','d071','d072','d071'],
  ['65167','d181','d182','d181'],
  ['65168','d061','d062','d061'],
  ['65171','a011','a012','a011'],
  ['65172','e061','e062','e061'],
  ['66003','a011','a012','a011'],
  ['66004','d501','d502','d501'],
  ['66007','a011','a012','a011'],
  ['66015','a151','a152','a151'],
  ['66016','a011','a012','a011'],
  ['66018','d011','d012','d011'],
  ['66021','a011','a012','a011'],
  ['66032','d501','d502','d501'],
  ['66033','a031','a032','a031'],
  ['66039','d501','d502','d501'],
  ['66043','a501','a502','a501'],
  ['66049','e031','e032','e031'],
  ['66051','a011','a012','a011'],
  ['66057','d011','d012','d011'],
  ['66058','d041','d042','d041'],
  ['66059','e881','e882','e881'],
  ['66060','a381','a382','a381'],
  ['66061','c061','c062','c061'],
  ['66063','a041','a042','a041'],
  ['66068','d381','d382','d381'],
  ['66073','e501','e502','e501'],
  ['66076','e051','e052','e051'],
  ['66079','d011','d012','d011'],
  ['66088','a031','a032','a031'],
  ['66089','a021','a022','a021'],
  ['66091','d081','d082','d081'],
  ['66092','d031','d032','d031'],
  ['66096','a041','a042','a041'],
  ['66097','e881','e882','e881'],
  ['66099','d381','d382','d381'],
  ['66102','d331','d332','d331'],
  ['66103','a441','a442','a441'],
  ['66111','d151','d152','d151'],
  ['66117','d381','d382','d381'],
  ['66119','d041','d042','d041'],
  ['66123','d031','d032','d031'],
  ['66129','a031','a032','a031'],
  ['66132','a881','a882','a881'],
  ['66135','f041','f042','f041'],
  ['66136','a181','a182','a181'],
  ['66137','a061','a062','a061'],
  ['66142','d051','d052','d051'],
  ['66147','d881','d882','d881'],
  ['66148','d581','d582','d581'],
  ['66152','f581','f582','f581'],
  ['66153','e181','e182','e181'],
  ['66156','a031','a032','a031'],
  ['66157','f041','f042','f041'],
  ['66158','d031','d032','d031'],
  ['66160','b581','b582','b581'],
  ['66166','b081','b082','b081'],
  ['67005','a501','a502','a501'],
  ['67006','a011','a012','a011'],
  ['67008','a151','a152','a151'],
  ['67009','a011','a012','a011'],
  ['67020','a051','a052','a051'],
  ['67039','d501','d502','d501'],
  ['67046','a581','a582','a581'],
  ['67051','d061','d062','d061'],
  ['67062','a011','a012','a011'],
  ['67068','a281','a282','a281'],
  ['67069','b881','b882','b881'],
  ['67083','e991','e992','e991'],
  ['67086','a011','a012','a011'],
  ['67087','b061','b062','b061'],
  ['67090','e061','e062','e061'],
  ['67093','e051','e052','e051'],
  ['67095','a011','a012','a011'],
  ['67097','a011','a012','a011'],
  ['67099','a011','a012','a011'],
  ['67100','a081','a082','a081'],
  ['67101','d011','d012','d011'],
  ['67103','a151','a152','a151'],
  ['67104','a051','a052','a051'],
  ['67108','a011','a012','a011'],
  ['67109','a011','a012','a011'],
  ['67124','a031','a032','a031'],
  ['67127','d051','d052','d051'],
  ['67130','d051','d052','d051'],
  ['67138','a181','a182','a181'],
  ['67139','a281','a282','a281'],
  ['67140','a281','a282','a281'],
  ['67144','d331','d332','d331'],
  ['67151','a331','a332','a331'],
  ['67152','a381','a382','a381'],
  ['67153','d331','d332','d331'],
  ['67154','a181','a182','a181'],
  ['67156','d281','d282','d281'],
  ['67163','d051','d052','d051'],
  ['67164','e041','e042','e041'],
  ['67502','e061','e062','e061'],
  ['67503','d041','d042','d041'],
  ['69005','d101','d102','d101'],
  ['69007','d011','d012','d011'],
  ['69010','d381','d382','d381'],
  ['69023','e061','e062','e061'],
  ['69027','b041','b042','b041'],
  ['69031','d181','d182','d181'],
  ['69032','d381','d382','d381'],
  ['69037','e041','e042','e041'],
  ['69047','d281','d282','d281'],
  ['69049','d041','d042','d041'],
  ['69055','e041','e042','e041'],
  ['69062','d041','d042','d041'],
  ['69063','a151','a152','a151'],
  ['69067','d051','d052','d051'],
  ['69069','d041','d042','d041'],
  ['69073','a051','a052','a051'],
  ['69076','d041','d042','d041'],
  ['69077','d011','d012','d011'],
  ['69078','d441','d442','d441'],
  ['69082','d331','d332','d331'],
  ['69083','b061','b062','b061'],
  ['69084','a051','a052','a051'],
  ['69086','d061','d062','d061'],
  ['69087','d381','d382','d381'],
  ['69091','a041','a042','a041'],
  ['69093','a041','a042','a041'],
  ['69508','f501','f502','f501'],
  ['69510','a031','a032','a031'],
  ['69515','e041','e042','e041'],
  ['69517','a041','a042','a041'],
  ['69518','a331','a332','a331'],
  ['69519','e581','e582','e581'],
  ['69520','e441','e442','e441'],
  ['69521','a041','a042','a041'],
  ['69523','d041','d042','d041'],
  ['69526','d031','d032','d031'],
  ['69527','e881','e882','e881'],
  ['69530','a041','a042','a041'],
  ['69533','a181','a182','a181'],
  ['69537','a331','a332','a331'],
  ['69538','e881','e882','e881'],
  ['69539','e151','e152','e151'],
  ['69543','d061','d062','d061'],
  ['69544','e041','e042','e041'],
  ['69545','e151','e152','e151'],
  ['69551','e151','e152','e151'],
  ['69552','a281','a282','a281'],
  ['69554','d181','d182','d181'],
  ['69555','a281','a282','a281'],
  ['69557','a281','a282','a281']
]

prefix_array.slice(0, 10).each_with_index do |config, i|
  company = Company.find_by_id(config[0])
  if company.present?
    old_trunk = $redis.hgetall("acdqueue:trunk:#{company.id}")
    puts "#{i} #{company.id} - before redis: #{old_trunk.inspect}"

    company.update!(manual_call_prefix: config[1],
                    task_prefix: config[2],
                    callback_prefix: config[3])

    $redis.mapped_hmset("acdqueue:trunk:#{company.id}", { manualcall_prefix: config[1],
                                                          task_prefix: config[2],
                                                          callback_prefix: config[3] })

    new_trunk = $redis.hgetall("acdqueue:trunk:#{company.id}")

    puts "#{i} #{company.id} - after  redis: #{new_trunk.inspect} pg: { manualcall_prefix: #{company.manual_call_prefix}, task_prefix: #{company.task_prefix}, callback_prefix: #{company.callback_prefix} }"
  else
    puts "#{i} 企业 #{config[0]} 不存在!"
  end
end