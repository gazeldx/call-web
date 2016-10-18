module BundlesHelper
  def bundle_title_hash(bundle)
    title = "<span align='left'>#{bundle.name.size > 6 ? "#{bundle.name}<br>" : nil}#{"#{t('bundle.ratio')}：#{bundle.ratio}<br>" if bundle.kind == Bundle::KIND_PREDICT}#{t('bundle.group')}：#{bundle.group.name}<br>#{"#{t('phone_number.number')}：#{bundle.number}<br>" if bundle.kind == Bundle::KIND_PREDICT}#{t('bundle.creator')}：#{bundle.creator.try(:name)} #{t('bundle.manager')}：#{bundle.manager.try(:name)}"
    title += "<br>#{t('bundle.remark')}：#{bundle.remark}" unless bundle.remark.blank?
    title += t(Bundle::IVR_MENUS[bundle.kind]) if title == Bundle::KIND_IVR
    title += '</span>'
    { 'data-original-title' => title, 'data-rel' => 'tooltip', 'data-html' => 'true' }
  end
end
