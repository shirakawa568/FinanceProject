select '汇  总'||count(distinct t.l_ztbh)||'个产品' 账套编号,to_char(sum(t.d_begin))||'条未生成未发送' 日期,''  发送时间,to_char(sum(t.l_czzt))||'条未收到' 操作状态,
       to_char(sum(t.l_wfh))||'条未返回' 托管是否返回,to_char(sum(t.jzyz))||'条数据一致' 一致,to_char(sum(t.jybyz))||'条数据不一致' 不一致
from(
    select  a.l_ztbh , nvl2(a.d_begin,0,1) d_begin,nvl2(a.d_scrq,1,0) d_scrq,a.l_czzt,
            a.l_fhzt,
            decode(a.l_fhzt,0,0,decode(a.l_zcjjjg,0,1,0))   jzyz,
            decode(a.l_fhzt,0,0,decode(a.l_zcjjjg,1,1,0))  jybyz,
        a.l_wfh
    from (
        select t.l_fundid l_ztbh, a.d_begin,a.d_scrq ,
            case
                when a.l_czzt in(2,3,6,7) then 0
                when a.l_czzt in(1,4,5)   then 1
                else 1 end
            l_czzt,decode(nvl(a.l_ids,0),0,0,1) l_fhzt,
            case
                when a.l_czzt in (2,3,7) then 1
                else 0 end
            l_wfh,nvl(a.l_zcjjjg,0) l_zcjjjg
        from  tfundinfo t,tsysinfo d,(
            select  a.l_ztbh ,a.l_id,a.d_begin,a.d_scrq, b.l_czzt l_fhczzt,a.l_czzt,
                decode(a.vc_wjlx,'1011',decode(nvl((
                    select count(1) jjjg
                    from tzhxy_ywmx m
                    where  m.l_2 =1
                        and m.s_1='0015'
                        and m.l_mainid(+)=b.l_id
                    group by m.l_mainid),0),0,0,1),2)
                l_zcjjjg ,row_number() over(partition by a.d_begin,a.d_end,a.l_ztbh,nvl(a.vc_wjlx,0)
            order by a.d_scrq desc,a.l_ID desc) rn ,b.l_id l_ids
            from tycdz_zb a ,tycdz_zb b
            where /*a.l_ztbh in (:l_ztbh)            and*/
                a.d_begin  >= date'2020-7-16'    and
                a.d_begin  <=date'2020-7-16'     and
                instr(','||'1001,1011,1031'||',', ','||nvl(a.vc_wjlx,'1001,1011,1031')||',') > 0  and
                a.l_sfbz  = 1           and
                a.l_id = b.l_glid(+)   and
                b.l_sfbz(+) = 0)  a
        where /*t.l_fundid in(:l_ztbh)and*/
            a.l_ztbh(+) = t.l_fundid  and
            a.rn(+) =1   and
            d.l_void=0 and
            t.l_fundid=d.l_id and
            (t.d_dqrq is null or t.d_dqrq> date'2020-7-16')and (d.d_destory is null or d.d_destory>date'2020-7-16')
            and t.vc_tgr='海通证券股份有限公司') a
    ) t