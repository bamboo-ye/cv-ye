import zipfile
import xml.etree.ElementTree as ET

docx = zipfile.ZipFile('叶晓艺简历.docx')

# 读取 document.xml
xml_content = docx.read('word/document.xml')
tree = ET.fromstring(xml_content)

namespaces = {
    'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main',
    'a': 'http://schemas.openxmlformats.org/drawingml/2006/main',
    'r': 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
}

# 读取 document.xml.rels 来获取图片关系
rels_content = docx.read('word/_rels/document.xml.rels')
rels_tree = ET.fromstring(rels_content)

# 构建图片映射
image_map = {}
for rel in rels_tree.findall('.//{http://schemas.openxmlformats.org/package/2006/relationships}Relationship'):
    rid = rel.get('Id')
    target = rel.get('Target')
    if 'media/' in target:
        image_map[rid] = target.replace('media/', 'images/')

# 提取段落，保留样式信息
paragraphs = []
for para in tree.findall('.//w:p', namespaces):
    # 检查段落样式（标题级别）
    pPr = para.find('.//w:pPr', namespaces)
    style_name = ''
    is_heading = False
    heading_level = 0
    
    if pPr is not None:
        # 检查是否是标题样式
        pStyle = pPr.find('.//w:pStyle', namespaces)
        if pStyle is not None:
            style_val = pStyle.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val')
            if style_val:
                style_name = style_val
                if 'Heading' in style_val:
                    is_heading = True
                    try:
                        heading_level = int(style_val.replace('Heading', ''))
                    except:
                        heading_level = 1
        
        # 检查大纲级别
        outlineLvl = pPr.find('.//w:outlineLvl', namespaces)
        if outlineLvl is not None:
            val = outlineLvl.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val')
            if val:
                is_heading = True
                heading_level = int(val) + 1
    
    # 提取文本和图片
    para_content = []
    has_image = False
    
    for elem in para.iter():
        tag = elem.tag.split('}')[-1] if '}' in elem.tag else elem.tag
        
        if tag == 't':
            if elem.text:
                para_content.append(('text', elem.text))
        elif tag == 'blip':
            embed = elem.get('{http://schemas.openxmlformats.org/officeDocument/2006/relationships}embed')
            if embed and embed in image_map:
                para_content.append(('image', image_map[embed]))
                has_image = True
    
    if para_content:
        text_content = ''.join([item[1] for item in para_content if item[0] == 'text']).strip()
        images = [item[1] for item in para_content if item[0] == 'image']
        
        if text_content or images:
            paragraphs.append({
                'text': text_content,
                'images': images,
                'is_heading': is_heading,
                'heading_level': heading_level,
                'style': style_name
            })

# 打印段落结构
print('Word 文档结构：')
print('=' * 60)
for i, para in enumerate(paragraphs):
    indent = '  ' * (para['heading_level'] - 1) if para['heading_level'] > 0 else ''
    prefix = '【H' + str(para['heading_level']) + '】' if para['is_heading'] else ''
    text = para['text'][:80] + '...' if len(para['text']) > 80 else para['text']
    print(f'{i+1:3d}. {indent}{prefix}{text}')
    if para['images']:
        for img in para['images']:
            print(f'      [图片: {img}]')

# 保存结构
with open('doc_structure.txt', 'w', encoding='utf-8') as f:
    for para in paragraphs:
        f.write(f"{para['text']}")
        f.write('\n')
        if para['images']:
            for img in para['images']:
                f.write(f'[IMAGE:{img}]\n')
        f.write('\n')

print(f'\n共提取 {len(paragraphs)} 个段落')
print('结构已保存到 doc_structure.txt')
